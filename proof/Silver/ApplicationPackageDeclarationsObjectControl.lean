module

public import Silver.ApplicationNativeCommands
public import Silver.ApplicationPackageDeclarationsStorage

@[expose] public section

/-! Object-reader control retains ordinary shared typed commands and one fixed
native count-growth/write pair. Its value reads only independent arguments and
the object's unchanged Boolean_Value field, never the newly active table cell. -/
namespace Silver.ApplicationPackageDeclarations.ObjectControl
open ApplicationNative

variable {Fn : Ty → Type}

def appendBoolean (object : ObjectResult) (first after : Nat) (mutable known : Bool) : ObjectResult :=
  {object with frame := {object.frame with booleanNames := object.frame.booleanNames ++
    [⟨first, after, mutable, 0, 0, known, object.booleanValue⟩]}}

theorem appendBoolean_nativeProjection (object : ObjectResult)
    (table : Storage.Table BooleanBindings.Binding) (first after : Nat) (mutable known : Bool)
    (represented : object.frame.booleanNames = table.active) (spare : table.count < table.cells.length) :
    (appendBoolean object first after mutable known).frame.booleanNames =
      (table.growAndWrite ⟨first, after, mutable, 0, 0, known, object.booleanValue⟩).active := by
  simp only [appendBoolean, Storage.growAndWrite_active table _ spare, represented]

inductive Command (Fn : Ty → Type)
  | native : ApplicationNative.Command Fn .objectResult → Command Fn
  | sequence : Command Fn → Command Fn → Command Fn
  | choose : Expr Fn .truth → Command Fn → Command Fn → Command Fn
  | appendBoolean : Place Fn .objectResult → Expr Fn .number → Expr Fn .number →
      Expr Fn .truth → Expr Fn .truth → Command Fn

def Command.eval (calls : Calls Fn) (locals : Locals) (next : Locals → ObjectResult) :
    Command Fn → ObjectResult
  | .native command => ApplicationNative.Command.eval (resultType := .objectResult) calls locals next command
  | .sequence first rest => first.eval calls locals (fun updated => rest.eval calls updated next)
  | .choose test yes no => if test.eval calls locals then yes.eval calls locals next else no.eval calls locals next
  | .appendBoolean target first after mutable known =>
      next (target.set calls locals (ObjectControl.appendBoolean (target.expression.eval calls locals)
        (first.eval calls locals) (after.eval calls locals) (mutable.eval calls locals) (known.eval calls locals)))

mutual
def Command.render (names : FunctionNames Fn) : Command Fn → List String
  | .native command => command.render names
  | .sequence first rest => first.render names ++ rest.render names
  | .choose test yes no => ["if"] ++ test.render names ++ ["then"] ++ yes.render names ++
      no.renderElse names ++ ["end", "if", ";"]
  | .appendBoolean target first after mutable known =>
      let table : Expr Fn .booleans := .field .stateBooleanNames (.field .objectFrame target.expression)
      let count : Expr Fn .number := .field .booleanCount table
      let slot : Expr Fn .booleanBinding := .index .boolean table count
      let item : Expr Fn .booleanBinding := .booleanBindingValue first after mutable (.number 0) (.number 0)
        known (.field .objectBooleanValue target.expression)
      count.render names ++ [":="] ++ (Expr.add count (.number 1)).render names ++ [";"] ++
        slot.render names ++ [":="] ++ item.render names ++ [";"]
def Command.renderElse (names : FunctionNames Fn) : Command Fn → List String
  | .native command => command.renderElse names
  | .choose test yes no => ["elsif"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names
  | command => ["else"] ++ command.render names
end

def Command.list (commands : List (Command Fn)) : Command Fn := commands.foldr .sequence (.native .nothing)

def Command.wellFormed (names : FunctionNames Fn) : Command Fn → Bool
  | .native command => command.wellFormed names
  | .sequence first rest => first.wellFormed names && rest.wellFormed names
  | .choose test yes no => test.logical && test.wellFormed names && yes.wellFormed names && no.wellFormed names
  | .appendBoolean target first after mutable known => target.expression.prefix && target.expression.wellFormed names &&
      first.expression && after.expression && mutable.expression && known.expression &&
      first.wellFormed names && after.wellFormed names && mutable.wellFormed names && known.wellFormed names

def Command.scoped (scope : Scope) (writable : List String) : Command Fn → Bool
  | .native command => command.scoped scope writable
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .appendBoolean target first after mutable known =>
      let independent := scope.filter (fun binding => binding.2 != target.root)
      decide (target.root ∈ writable) && target.expression.scoped scope &&
        first.scoped independent && after.scoped independent && mutable.scoped independent && known.scoped independent

def Command.namedCorrect (parameters : FunctionParameters Fn) : Command Fn → Bool
  | .native command => command.namedCorrect parameters
  | .sequence first rest => first.namedCorrect parameters && rest.namedCorrect parameters
  | .choose test yes no => test.namedCorrect parameters && yes.namedCorrect parameters && no.namedCorrect parameters
  | .appendBoolean target first after mutable known => target.expression.namedCorrect parameters &&
      first.namedCorrect parameters && after.namedCorrect parameters && mutable.namedCorrect parameters && known.namedCorrect parameters

structure Body (Fn : Ty → Type) where
  name : String
  declarations : List (Declaration Fn)
  commands : Command Fn

def Body.render (names : FunctionNames Fn) (body : Body Fn) : List String :=
  body.declarations.flatMap (Declaration.render names) ++ ["begin"] ++ body.commands.render names ++ ["end", body.name, ";"]

def Body.eval (body : Body Fn) (calls : Calls Fn) (locals : Locals) : ObjectResult :=
  body.commands.eval calls (body.declarations.foldl (Declaration.eval calls) locals) (fun _ => invalidObject)

def Body.wellFormed (names : FunctionNames Fn) (body : Body Fn) : Bool :=
  identifier body.name && decide (body.declarations.flatMap Declaration.names).Nodup &&
    body.declarations.all (Declaration.wellFormed names) && body.commands.wellFormed names

def Body.scoped (scope : Scope) (body : Body Fn) : Bool :=
  let inside := Declarations.scan scope [] body.declarations
  inside.1 && body.commands.scoped inside.2.1 inside.2.2

def Body.namedCorrect (parameters : FunctionParameters Fn) (body : Body Fn) : Bool :=
  body.declarations.all (Declaration.namedCorrect parameters) && body.commands.namedCorrect parameters

end Silver.ApplicationPackageDeclarations.ObjectControl
