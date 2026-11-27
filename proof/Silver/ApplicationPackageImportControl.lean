module

public import Silver.ApplicationNativeCommands

@[expose] public section

/-! Control for Imported_Package's two nested plain loops. Return captures its
value before block restoration; exit restores locals and leaves only the nearest
loop. The ordinary expression, declaration and place checks are shared with the
other native package trees. Fuel bounds execution here, not language membership. -/
namespace Silver.ApplicationPackageImport.Control
open ApplicationNative

inductive Command (Fn : Ty → Type)
  | nothing
  | assign : Place Fn ty → Expr Fn ty → Command Fn
  | sequence : Command Fn → Command Fn → Command Fn
  | choose : Expr Fn .truth → Command Fn → Command Fn → Command Fn
  | block : List (Declaration Fn) → Command Fn → Command Fn
  | loopBody : Command Fn → Command Fn
  | exitWhen : Expr Fn .truth → Command Fn
  | exited
  | invariant : Expr Fn .truth → Command Fn
  | increases : Expr Fn .number → Command Fn
  | returned : Expr Fn .source → Command Fn

variable {Fn : Ty → Type}
abbrev Continuation := Locals → Option Source

def loop (body : Locals → Continuation → Continuation → Option Source)
    (next : Continuation) : Nat → Continuation
  | 0, _ => none
  | fuel + 1, locals => body locals (loop body next fuel) next

def Command.eval (functions : Calls Fn) (fuel : Nat) (locals : Locals)
    (next leave : Continuation) : Command Fn → Option Source
  | .nothing | .invariant _ | .increases _ => next locals
  | .assign target value => next (target.set functions locals (value.eval functions locals))
  | .sequence first rest => first.eval functions fuel locals
      (fun updated => rest.eval functions fuel updated next leave) leave
  | .choose test yes no => if test.eval functions locals then yes.eval functions fuel locals next leave
      else no.eval functions fuel locals next leave
  | .block declarations body =>
      let restore := Declarations.restore declarations locals
      body.eval functions fuel (declarations.foldl (Declaration.eval functions) locals)
        (fun updated => next (restore updated)) (fun updated => leave (restore updated))
  | .loopBody body => loop (fun current cont exitLoop => body.eval functions fuel current cont exitLoop) next fuel locals
  | .exitWhen test => if test.eval functions locals then leave locals else next locals
  | .exited => leave locals
  | .returned value => some (value.eval functions locals)

def Command.list (commands : List (Command Fn)) : Command Fn := commands.foldr .sequence .nothing

mutual
def Command.render (names : FunctionNames Fn) : Command Fn → List String
  | .nothing => []
  | .assign place value => place.expression.render names ++ [":="] ++ value.render names ++ [";"]
  | .sequence first rest => first.render names ++ rest.render names
  | .choose test yes no => ["if"] ++ test.render names ++ ["then"] ++ yes.render names ++
      no.renderElse names ++ ["end", "if", ";"]
  | .block declarations body => ["declare"] ++ declarations.flatMap (Declaration.render names) ++
      ["begin"] ++ body.render names ++ ["end", ";"]
  | .loopBody body => ["loop"] ++ body.render names ++ ["end", "loop", ";"]
  | .exitWhen test => ["exit", "when"] ++ test.render names ++ [";"]
  | .exited => ["exit", ";"]
  | .invariant test => ["pragma", "loop_invariant", "("] ++ test.render names ++ [")", ";"]
  | .increases value => ["pragma", "loop_variant", "(", "increases", "=>"] ++ value.render names ++ [")", ";"]
  | .returned value => ["return"] ++ value.render names ++ [";"]
def Command.renderElse (names : FunctionNames Fn) : Command Fn → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names
  | command => ["else"] ++ command.render names
end

def Command.wellFormed (names : FunctionNames Fn) (insideLoop : Bool) : Command Fn → Bool
  | .nothing => true
  | .assign place value => place.expression.wellFormed names && value.expression && value.wellFormed names
  | .sequence first rest => first.wellFormed names insideLoop && rest.wellFormed names insideLoop
  | .choose test yes no => test.logical && test.wellFormed names &&
      yes.wellFormed names insideLoop && no.wellFormed names insideLoop
  | .block declarations body => decide (declarations.flatMap Declaration.names).Nodup &&
      declarations.all (Declaration.wellFormed names) && body.wellFormed names insideLoop
  | .loopBody body => body.wellFormed names true
  | .exitWhen test => insideLoop && test.logical && test.wellFormed names
  | .exited => insideLoop
  | .invariant test => insideLoop && (test.logical || test.conditional || test.quantified) && test.wellFormed names
  | .increases value => insideLoop && value.simple && value.wellFormed names
  | .returned value => value.expression && value.wellFormed names

def Command.scoped (scope : Scope) (writable : List String) : Command Fn → Bool
  | .nothing | .exited => true
  | .assign place value => decide (place.root ∈ writable) && place.expression.scoped scope && value.scoped scope
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .block declarations body =>
      let scanned := Declarations.scan scope writable declarations
      scanned.1 && body.scoped scanned.2.1 scanned.2.2
  | .loopBody body => body.scoped scope writable
  | .exitWhen test | .invariant test => test.scoped scope
  | .increases value | .returned value => value.scoped scope

def Command.namedCorrect (parameters : FunctionParameters Fn) : Command Fn → Bool
  | .nothing | .exited => true
  | .assign place value => place.expression.namedCorrect parameters && value.namedCorrect parameters
  | .sequence first rest => first.namedCorrect parameters && rest.namedCorrect parameters
  | .choose test yes no => test.namedCorrect parameters && yes.namedCorrect parameters && no.namedCorrect parameters
  | .block declarations body => declarations.all (Declaration.namedCorrect parameters) && body.namedCorrect parameters
  | .loopBody body => body.namedCorrect parameters
  | .exitWhen test | .invariant test => test.namedCorrect parameters
  | .increases value | .returned value => value.namedCorrect parameters

end Silver.ApplicationPackageImport.Control
