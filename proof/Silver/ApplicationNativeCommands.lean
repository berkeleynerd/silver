module

public import Silver.ApplicationNativeGuards

@[expose] public section

/-! Typed assignments and bounded Ada loops for package frame helpers.
Loop bounds are evaluated once at entry, early returns propagate through every
enclosing command, and the loop parameter's outer binding is restored on exit.
Active-prefix table updates have the representation scope documented in the
expression core; the frame interpretation proves their index bounds. Loop
invariants are retained as typed annotations and have no state effect here;
their complete proof obligations remain part of the native checkpoint. -/
namespace Silver.ApplicationNative

inductive Place (Fn : Ty → Type) : Ty → Type
  | variable (name : String) : Place Fn ty
  | field : Field owner ty → Place Fn owner → Place Fn ty
  | index : Index owner index ty → Place Fn owner → Expr Fn index → Place Fn ty

variable {Fn : Ty → Type} {resultType : Ty}

def Place.expression : Place Fn ty → Expr Fn ty
  | .variable name => .variable name
  | .field projection owner => .field projection owner.expression
  | .index selection owner key => .index selection owner.expression key

def Place.set (calls : Calls Fn) (locals : Locals) : Place Fn ty → ty.meaning → Locals
  | .variable name, value => locals.set _ name value
  | .field projection owner, value =>
      owner.set calls locals (projection.set (owner.expression.eval calls locals) value)
  | .index selection owner key, value =>
      owner.set calls locals (selection.set (owner.expression.eval calls locals) (key.eval calls locals) value)

inductive Command (Fn : Ty → Type) (resultType : Ty)
  | nothing
  | assign : Place Fn ty → Expr Fn ty → Command Fn resultType
  | sequence : Command Fn resultType → Command Fn resultType → Command Fn resultType
  | choose : Expr Fn .truth → Command Fn resultType → Command Fn resultType → Command Fn resultType
  | invariant : Expr Fn .truth → Command Fn resultType
  | forRange (name : String) : Expr Fn .number → Expr Fn .number →
      Command Fn resultType → Command Fn resultType
  | returned : Expr Fn resultType → Command Fn resultType

/-- Execute consecutive inclusive range values with an ordinary early-return
continuation. A null range executes no body. -/
def forValues (body : Locals → (Locals → resultType.meaning) → resultType.meaning)
    (name : String) (values : List Nat) (locals : Locals)
    (next : Locals → resultType.meaning) : resultType.meaning :=
  match values with
  | [] => next locals
  | value :: rest => body (locals.set .number name value)
      (fun updated => forValues body name rest updated next)

def Command.eval (calls : Calls Fn) (locals : Locals) (next : Locals → resultType.meaning) :
    Command Fn resultType → resultType.meaning
  | .nothing => next locals
  | .assign place value => next (place.set calls locals (value.eval calls locals))
  | .sequence first rest => first.eval calls locals (fun updated => rest.eval calls updated next)
  | .choose test yes no => if test.eval calls locals then yes.eval calls locals next else no.eval calls locals next
  | .invariant _ => next locals
  | .forRange name first last body =>
      let low := first.eval calls locals
      let values := (List.range (last.eval calls locals + 1 - low)).map (low + ·)
      forValues (fun current continuation => body.eval calls current continuation) name values locals
        (fun updated => next (updated.set .number name (locals .number name)))
  | .returned value => value.eval calls locals

mutual
def Command.render (names : FunctionNames Fn) : Command Fn resultType → List String
  | .nothing => []
  | .assign place value => place.expression.render names ++ [":="] ++ value.render names ++ [";"]
  | .sequence first rest => first.render names ++ rest.render names
  | .choose test yes no => ["if"] ++ test.render names ++ ["then"] ++ yes.render names ++
      no.renderElse names ++ ["end", "if", ";"]
  | .invariant test => ["pragma", "loop_invariant", "("] ++ test.render names ++ [")", ";"]
  | .forRange name first last body => ["for", name, "in"] ++ first.render names ++ [".."] ++
      last.render names ++ ["loop"] ++ body.render names ++ ["end", "loop", ";"]
  | .returned value => ["return"] ++ value.render names ++ [";"]
def Command.renderElse (names : FunctionNames Fn) : Command Fn resultType → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names
  | command => ["else"] ++ command.render names
end

def Command.list (commands : List (Command Fn resultType)) : Command Fn resultType :=
  commands.foldr .sequence .nothing

structure Declaration (Fn : Ty → Type) where
  type : Ty
  name : String
  typeName : List String
  constant : Bool := false
  initial : Expr Fn type

def Declaration.render (names : FunctionNames Fn) (declaration : Declaration Fn) : List String :=
  [declaration.name, ":"] ++ (if declaration.constant then ["constant"] else []) ++
    declaration.typeName ++ [":="] ++ declaration.initial.render names ++ [";"]

def Declaration.eval (calls : Calls Fn) (locals : Locals) (declaration : Declaration Fn) : Locals :=
  locals.set declaration.type declaration.name (declaration.initial.eval calls locals)

structure Body (Fn : Ty → Type) (resultType : Ty) where
  name : String
  declarations : List (Declaration Fn)
  commands : Command Fn resultType

def Body.render (names : FunctionNames Fn) (body : Body Fn resultType) : List String :=
  body.declarations.flatMap (Declaration.render names) ++ ["begin"] ++
    body.commands.render names ++ ["end", body.name, ";"]

def Body.eval (body : Body Fn resultType) (calls : Calls Fn) (locals : Locals) : resultType.meaning :=
  body.commands.eval calls (body.declarations.foldl (Declaration.eval calls) locals) (fun _ => resultType.default)

def Place.root : Place Fn ty → String
  | .variable name => name
  | .field _ owner | .index _ owner _ => owner.root

def Declaration.validType : Ty → List String → Bool
  | .number, spelling => decide (spelling ∈ [["literal_position"], ["subtype_count"],
      ["boolean_count"], ["scalar_expressions", ".", "binding_count"],
      ["packages", ".", "export_count_type"]])
  | .state, spelling => spelling == ["parser_state"]
  | .functionType, spelling => spelling == ["function_type_result"]
  | _, _ => false

def Declaration.wellFormed (names : FunctionNames Fn) (declaration : Declaration Fn) : Bool :=
  identifier declaration.name && Declaration.validType declaration.type declaration.typeName &&
    declaration.initial.expression && declaration.initial.wellFormed names

def Command.wellFormed (names : FunctionNames Fn) : Command Fn resultType → Bool
  | .nothing => true
  | .assign place value => place.expression.wellFormed names && value.expression && value.wellFormed names
  | .sequence first rest => first.wellFormed names && rest.wellFormed names
  | .choose test yes no => test.logical && test.wellFormed names && yes.wellFormed names && no.wellFormed names
  | .invariant test => test.logical && test.wellFormed names
  | .forRange name first last body => identifier name && first.simple && last.simple &&
      first.wellFormed names && last.wellFormed names && body.wellFormed names
  | .returned value => value.expression && value.wellFormed names

def Command.scoped (scope : Scope) (writable : List String) : Command Fn resultType → Bool
  | .nothing => true
  | .assign place value => decide (place.root ∈ writable) &&
      place.expression.scoped scope && value.scoped scope
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .invariant test => test.scoped scope
  | .forRange name first last body => first.scoped scope && last.scoped scope &&
      body.scoped (scope.bind .number name) (writable.filter (· != name))
  | .returned value => value.scoped scope

def Body.wellFormed (names : FunctionNames Fn) (body : Body Fn resultType) : Bool :=
  identifier body.name && decide (body.declarations.map Declaration.name).Nodup &&
    body.declarations.all (Declaration.wellFormed names) && body.commands.wellFormed names

def Body.scoped (scope : Scope) (body : Body Fn resultType) : Bool :=
  let scanned := body.declarations.foldl (fun (result : Bool × Scope × List String) declaration =>
    (result.1 && declaration.initial.scoped result.2.1,
      result.2.1.bind declaration.type declaration.name,
      if declaration.constant then result.2.2.filter (· != declaration.name)
      else declaration.name :: result.2.2.filter (· != declaration.name))) (true, scope, [])
  scanned.1 && body.commands.scoped scanned.2.1 scanned.2.2

end Silver.ApplicationNative
