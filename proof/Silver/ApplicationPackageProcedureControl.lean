module

public import Silver.ApplicationNativeCommands
public import Silver.ApplicationPackageBodiesCompletion
public import Silver.ApplicationPackageDeclarationsStorage

@[expose] public section

/-! Typed procedure control used by package completion and body readers. Calls
have fixed native identities and typed in/out positions. The count-growth/write
pair is a distinct source idiom, whose active-table projection is proved by
Declarations.Storage.growAndWrite_active; ordinary count setters do not grow a
table. While fuel only bounds this meta-level evaluator and is eliminated by
native cursor bounds and progress when interpreting each complete helper. -/
namespace Silver.ApplicationPackageProcedure
open ApplicationNative ApplicationPackageBodies ApplicationPackageDeclarations

variable {Fn : Ty → Type}

structure ProcedureCalls where
  signature : Source → Compose.ParserState → PackageBindings.Metadata → Bool → SignatureResult
  appendFormal : Compose.ParserState → PackageBindings.NameSpan → ApplicationPackageNames.PackageTypeResult →
    ProcedureBindings.Mode → Compose.ParserState
  completion : Source → Compose.ParserState → PackageBindings.Metadata → CompletionResult

inductive Primitive (Fn : Ty → Type)
  | signature : Expr Fn .source → Expr Fn .state → Place Fn .metadata → Expr Fn .truth → Place Fn .state → Primitive Fn
  | appendFormal : Place Fn .state → Expr Fn .nameSpan → Expr Fn .packageType → Expr Fn .mode → Primitive Fn
  | completion : Expr Fn .source → Place Fn .state → Place Fn .metadata → Primitive Fn
  | growState : Place Fn .metadata → Expr Fn .stateDeclaration → Primitive Fn

def grownMetadata (info : PackageBindings.Metadata) (value : PackageBindings.StateDeclaration) :
    PackageBindings.Metadata := {info with states := info.states ++ [value]}

theorem grownMetadata_nativeProjection (info : PackageBindings.Metadata)
    (table : ApplicationPackageDeclarations.Storage.Table PackageBindings.StateDeclaration)
    (value : PackageBindings.StateDeclaration) (represented : info.states = table.active)
    (spare : table.count < table.cells.length) :
    (grownMetadata info value).states = (table.growAndWrite value).active := by
  simp only [grownMetadata, ApplicationPackageDeclarations.Storage.growAndWrite_active table value spare,
    represented]

def Primitive.eval (functions : Calls Fn) (procedures : ProcedureCalls) (locals : Locals) : Primitive Fn → Locals
  | .signature text outer info completing header =>
      let result := procedures.signature (text.eval functions locals) (outer.eval functions locals)
        (info.expression.eval functions locals) (completing.eval functions locals)
      let updated := info.set functions locals result.info
      header.set functions updated result.header
  | .appendFormal frame name mark mode =>
      frame.set functions locals (procedures.appendFormal (frame.expression.eval functions locals)
        (name.eval functions locals) (mark.eval functions locals) (mode.eval functions locals))
  | .completion text globals info =>
      let result := procedures.completion (text.eval functions locals)
        (globals.expression.eval functions locals) (info.expression.eval functions locals)
      let updated := globals.set functions locals result.globals
      info.set functions updated result.info
  | .growState info value =>
      let current := info.expression.eval functions locals
      info.set functions locals (grownMetadata current (value.eval functions locals))

def Primitive.render (names : FunctionNames Fn) : Primitive Fn → List String
  | .signature text outer info completing header =>
      ["package_signature_at", "("] ++ text.render names ++ [","] ++ outer.render names ++ [","] ++
        info.expression.render names ++ [","] ++ completing.render names ++ [","] ++
        header.expression.render names ++ [")", ";"]
  | .appendFormal frame name mark mode =>
      ["append_package_formal", "("] ++ frame.expression.render names ++ [","] ++ name.render names ++
        [","] ++ mark.render names ++ [","] ++ mode.render names ++ [")", ";"]
  | .completion text globals info =>
      ["package_completion_at", "("] ++ text.render names ++ [","] ++ globals.expression.render names ++
        [","] ++ info.expression.render names ++ [")", ";"]
  | .growState info value =>
      let count : Expr Fn .number := .field .stateCount info.expression
      let slot : Expr Fn .stateDeclaration := .index .state info.expression count
      count.render names ++ [":="] ++ (Expr.add count (.number 1)).render names ++ [";"] ++
        slot.render names ++ [":="] ++ value.render names ++ [";"]

def Primitive.allExpressions (test : {ty : Ty} → Expr Fn ty → Bool) : Primitive Fn → Bool
  | .signature text outer info completing header =>
      test text && test outer && test info.expression && test completing && test header.expression
  | .appendFormal frame name mark mode => test frame.expression && test name && test mark && test mode
  | .completion text globals info => test text && test globals.expression && test info.expression
  | .growState info value => test info.expression && test value

def Primitive.writtenRoots : Primitive Fn → List String
  | .signature _ _ info _ header => [info.root, header.root]
  | .appendFormal frame _ _ _ => [frame.root]
  | .completion _ globals info => [globals.root, info.root]
  | .growState info _ => [info.root]

def Primitive.wellFormed (names : FunctionNames Fn) (primitive : Primitive Fn) : Bool :=
  primitive.allExpressions (fun value => value.expression && value.wellFormed names) &&
    decide primitive.writtenRoots.Nodup

def Primitive.scoped (scope : Scope) (writable : List String) (primitive : Primitive Fn) : Bool :=
  primitive.allExpressions (fun value => value.scoped scope) &&
    primitive.writtenRoots.all (fun name => name ∈ writable) &&
    match primitive with
    | .growState info value => value.scoped (scope.filter (fun binding => binding.2 != info.root))
    | _ => true

inductive Command (Fn : Ty → Type)
  | nothing
  | assign : Place Fn ty → Expr Fn ty → Command Fn
  | primitive : Primitive Fn → Command Fn
  | sequence : Command Fn → Command Fn → Command Fn
  | choose : Expr Fn .truth → Command Fn → Command Fn → Command Fn
  | block : List (Declaration Fn) → Command Fn → Command Fn
  | whileLoop : Expr Fn .truth → Command Fn → Command Fn
  | forRange (name : String) : Expr Fn .number → Expr Fn .number → Command Fn → Command Fn
  | invariant : Expr Fn .truth → Command Fn
  | increases : Expr Fn .number → Command Fn
  | returned

structure Outcome where
  locals : Locals
  returned : Bool := false

def Outcome.bind (result : Outcome) (next : Locals → Option Outcome) : Option Outcome :=
  if result.returned then some result else next result.locals

def Outcome.restore (result : Outcome) (restore : Locals → Locals) : Outcome :=
  {result with locals := restore result.locals}

def forLocals (body : Locals → Option Outcome) (name : String) : List Nat → Locals → Option Outcome
  | [], locals => some ⟨locals, false⟩
  | value :: rest, locals => (body (locals.set .number name value)).bind fun result =>
      result.bind (forLocals body name rest)

def whileLocals (test : Locals → Bool) (body : Locals → Option Outcome) : Nat → Locals → Option Outcome
  | 0, _ => none
  | fuel + 1, locals =>
      if test locals then (body locals).bind fun result => result.bind (whileLocals test body fuel)
      else some ⟨locals, false⟩

def Command.eval (functions : Calls Fn) (procedures : ProcedureCalls) (fuel : Nat) :
    Command Fn → Locals → Option Outcome
  | .nothing, locals => some ⟨locals, false⟩
  | .assign target value, locals => some ⟨target.set functions locals (value.eval functions locals), false⟩
  | .primitive call, locals => some ⟨call.eval functions procedures locals, false⟩
  | .sequence first rest, locals => (first.eval functions procedures fuel locals).bind fun result =>
      result.bind (rest.eval functions procedures fuel)
  | .choose test yes no, locals =>
      if test.eval functions locals then yes.eval functions procedures fuel locals
      else no.eval functions procedures fuel locals
  | .block declarations body, locals =>
      (body.eval functions procedures fuel (declarations.foldl (Declaration.eval functions) locals)).map
        (fun result => result.restore (Declarations.restore declarations locals))
  | .whileLoop test body, locals =>
      whileLocals (test.eval functions) (body.eval functions procedures fuel) fuel locals
  | .forRange name first last body, locals =>
      let low := first.eval functions locals
      let values := (List.range (last.eval functions locals + 1 - low)).map (low + ·)
      (forLocals (body.eval functions procedures fuel) name values locals).map
        (fun result => result.restore (fun updated => updated.set .number name (locals .number name)))
  | .invariant _, locals | .increases _, locals => some ⟨locals, false⟩
  | .returned, locals => some ⟨locals, true⟩

mutual
def Command.render (names : FunctionNames Fn) : Command Fn → List String
  | .nothing => []
  | .assign target value => target.expression.render names ++ [":="] ++ value.render names ++ [";"]
  | .primitive call => call.render names
  | .sequence first rest => first.render names ++ rest.render names
  | .choose test yes no => ["if"] ++ test.render names ++ ["then"] ++ yes.render names ++
      no.renderElse names ++ ["end", "if", ";"]
  | .block declarations body => ["declare"] ++ declarations.flatMap (Declaration.render names) ++
      ["begin"] ++ body.render names ++ ["end", ";"]
  | .whileLoop test body => ["while"] ++ test.render names ++ ["loop"] ++ body.render names ++ ["end", "loop", ";"]
  | .forRange name first last body => ["for", name, "in"] ++ first.render names ++ [".."] ++
      last.render names ++ ["loop"] ++ body.render names ++ ["end", "loop", ";"]
  | .invariant test => ["pragma", "loop_invariant", "("] ++ test.render names ++ [")", ";"]
  | .increases value => ["pragma", "loop_variant", "(", "increases", "=>"] ++ value.render names ++ [")", ";"]
  | .returned => ["return", ";"]
def Command.renderElse (names : FunctionNames Fn) : Command Fn → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names
  | command => ["else"] ++ command.render names
end

def Command.list (commands : List (Command Fn)) : Command Fn := commands.foldr .sequence .nothing

def Command.wellFormed (names : FunctionNames Fn) : Command Fn → Bool
  | .nothing | .returned => true
  | .assign target value => target.expression.wellFormed names && value.expression && value.wellFormed names
  | .primitive call => call.wellFormed names
  | .sequence first rest => first.wellFormed names && rest.wellFormed names
  | .choose test yes no => test.logical && test.wellFormed names && yes.wellFormed names && no.wellFormed names
  | .block declarations body => declarations.all (Declaration.wellFormed names) &&
      decide (declarations.flatMap Declaration.names).Nodup && body.wellFormed names
  | .whileLoop test body => test.logical && test.wellFormed names && body.wellFormed names
  | .forRange name first last body => identifier name && first.simple && last.simple &&
      first.wellFormed names && last.wellFormed names && body.wellFormed names
  | .invariant test => test.logical && test.wellFormed names
  | .increases value => value.simple && value.wellFormed names

def Command.scoped (scope : Scope) (writable : List String) : Command Fn → Bool
  | .nothing | .returned => true
  | .assign target value => decide (target.root ∈ writable) && target.expression.scoped scope && value.scoped scope
  | .primitive call => call.scoped scope writable
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .block declarations body =>
      let inside := Declarations.scan scope writable declarations
      inside.1 && body.scoped inside.2.1 inside.2.2
  | .whileLoop test body => test.scoped scope && body.scoped scope writable
  | .forRange name first last body => first.scoped scope && last.scoped scope &&
      body.scoped (scope.bind .number name) (writable.filter (· != name))
  | .invariant test => test.scoped scope
  | .increases value => value.scoped scope

def Command.namedCorrect (parameters : FunctionParameters Fn) : Command Fn → Bool
  | .nothing | .returned => true
  | .assign target value => target.expression.namedCorrect parameters && value.namedCorrect parameters
  | .primitive call => call.allExpressions (fun value => value.namedCorrect parameters)
  | .sequence first rest => first.namedCorrect parameters && rest.namedCorrect parameters
  | .choose test yes no => test.namedCorrect parameters && yes.namedCorrect parameters && no.namedCorrect parameters
  | .block declarations body => declarations.all (Declaration.namedCorrect parameters) && body.namedCorrect parameters
  | .whileLoop test body => test.namedCorrect parameters && body.namedCorrect parameters
  | .forRange _ first last body => first.namedCorrect parameters && last.namedCorrect parameters && body.namedCorrect parameters
  | .invariant test => test.namedCorrect parameters
  | .increases value => value.namedCorrect parameters

structure Body (Fn : Ty → Type) where
  name : String
  declarations : List (Declaration Fn)
  commands : Command Fn

def Body.render (names : FunctionNames Fn) (body : Body Fn) : List String :=
  body.declarations.flatMap (Declaration.render names) ++ ["begin"] ++ body.commands.render names ++ ["end", body.name, ";"]

def Body.eval (body : Body Fn) (functions : Calls Fn) (procedures : ProcedureCalls) (fuel : Nat) (locals : Locals) :
    Option Locals :=
  (body.commands.eval functions procedures fuel (body.declarations.foldl (Declaration.eval functions) locals)).map
    Outcome.locals

def Body.wellFormed (names : FunctionNames Fn) (body : Body Fn) : Bool :=
  identifier body.name && body.declarations.all (Declaration.wellFormed names) &&
    decide (body.declarations.flatMap Declaration.names).Nodup && body.commands.wellFormed names

def Body.scoped (scope : Scope) (writable : List String) (body : Body Fn) : Bool :=
  let inside := Declarations.scan scope writable body.declarations
  inside.1 && body.commands.scoped inside.2.1 inside.2.2

def Body.namedCorrect (parameters : FunctionParameters Fn) (body : Body Fn) : Bool :=
  body.declarations.all (Declaration.namedCorrect parameters) && body.commands.namedCorrect parameters

end Silver.ApplicationPackageProcedure
