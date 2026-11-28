module

public import Silver.ApplicationPackageProcedureControl

@[expose] public section

/-! The declaration readers each have one plain Ada loop. Statements can
continue, return from the procedure, or exit the surrounding loop. A guarded
loop retains its source prelude and no fuel is part of the meaning. -/
namespace Silver.ApplicationPackageDeclarations.Control
open ApplicationNative
open ApplicationPackageProcedure (Primitive ProcedureCalls)

variable {Fn : Ty → Type}

def call2 (symbol : Fn (.arrow a (.arrow b c))) (x : Expr Fn a) (y : Expr Fn b) : Expr Fn c :=
  .app (.app (.function symbol) x) y

def call3 (symbol : Fn (.arrow a (.arrow b (.arrow c d)))) (x : Expr Fn a) (y : Expr Fn b)
    (z : Expr Fn c) : Expr Fn d := .app (call2 symbol x y) z

def call4 (symbol : Fn (.arrow a (.arrow b (.arrow c (.arrow d e))))) (w : Expr Fn a) (x : Expr Fn b)
    (y : Expr Fn c) (z : Expr Fn d) : Expr Fn e := .app (call3 symbol w x y) z

def constant (ty : Ty) (name : String) (spelling : List String) (value : Expr Fn ty) : Declaration Fn :=
  ⟨ty, name, spelling, true, some value, [], none⟩

def localDeclaration (ty : Ty) (name : String) (spelling : List String)
    (additionalNames : List String := []) (initial : Option (Expr Fn ty) := none) : Declaration Fn :=
  ⟨ty, name, spelling, false, initial, additionalNames, none⟩

inductive TableKind | parameters | routines | exports

structure Backing where
  formal : Locals → Nat → PackageBindings.Formal
  routine : Locals → Nat → PackageBindings.Routine
  exportItem : Locals → Nat → PackageBindings.ExportDeclaration

def TableKind.count : TableKind → Field .metadata .number
  | .parameters => .parameterCount | .routines => .routineCount | .exports => .exportCount

def TableKind.resize (kind : TableKind) (backing : Backing) (locals : Locals)
    (info : PackageBindings.Metadata) (count : Nat) : PackageBindings.Metadata :=
  match kind with
  | .parameters => {info with parameters := Storage.resize info.parameters (backing.formal locals) count}
  | .routines => {info with routines := Storage.resize info.routines (backing.routine locals) count}
  | .exports => {info with exports := Storage.resize info.exports (backing.exportItem locals) count}

/-- The loop-entry invariants retain original unit spans and formal-table
bounds. Annotations affect native verification, not executable state. -/
inductive Annotation (Fn : Ty → Type)
  | invariant : Expr Fn .truth → Annotation Fn
  | assertion : Expr Fn .truth → Annotation Fn
  | increases : Expr Fn .number → Annotation Fn
  | stableUnits : Expr Fn .metadata → Annotation Fn
  | completingFormals : Expr Fn .truth → Expr Fn .number → Expr Fn .routine →
      Expr Fn .number → Expr Fn .metadata → Annotation Fn

def Annotation.render (names : FunctionNames Fn) : Annotation Fn → List String
  | .invariant value => ["pragma","loop_invariant","("] ++ value.render names ++ [")",";"]
  | .assertion value => ["pragma","assert","("] ++ value.render names ++ [")",";"]
  | .increases value => ["pragma","loop_variant","(","increases","=>"] ++ value.render names ++ [")",";"]
  | .stableUnits info => ["pragma","loop_invariant","("] ++ info.render names ++
      [".","units","="] ++ info.render names ++ ["'","loop_entry",".","units",")",";"]
  | .completingFormals completing start item count info =>
      ["pragma","loop_invariant","(","if"] ++ completing.render names ++ ["then"] ++
        start.render names ++ ["="] ++ (Expr.field .routineFormalFirst item).render names ++ ["and","then"] ++
        count.render names ++ ["<="] ++ (Expr.field .routineFormalCount item).render names ++ ["and","then"] ++
        (Expr.field .parameterCount info).render names ++ ["="] ++ info.render names ++
        ["'","loop_entry",".","parameter_count",")",";"]

def Annotation.wellFormed (names : FunctionNames Fn) : Annotation Fn → Bool
  | .invariant test | .assertion test => (test.logical || test.conditional || test.quantified) && test.wellFormed names
  | .increases value => value.simple && value.wellFormed names
  | .stableUnits info => info.prefix && info.wellFormed names
  | .completingFormals completing start item count info =>
      completing.logical && start.simple && item.prefix && count.simple && info.prefix &&
      completing.wellFormed names && start.wellFormed names && item.wellFormed names &&
      count.wellFormed names && info.wellFormed names

def Annotation.allExpressions (test : {ty : Ty} → Expr Fn ty → Bool) : Annotation Fn → Bool
  | .invariant value | .assertion value | .increases value => test value
  | .stableUnits info => test info
  | .completingFormals completing start item count info => test completing && test start &&
      test item && test count && test info

inductive Statement (Fn : Ty → Type)
  | nothing
  | assign : Place Fn ty → Expr Fn ty → Statement Fn
  | resize : TableKind → Place Fn .metadata → Expr Fn .number → Statement Fn
  | call : Primitive Fn → Statement Fn
  | sequence : Statement Fn → Statement Fn → Statement Fn
  | choose : Expr Fn .truth → Statement Fn → Statement Fn → Statement Fn
  | block : List (Declaration Fn) → Statement Fn → Statement Fn
  | annotate : Annotation Fn → Statement Fn
  | returned
  | exited
  | exitWhen : Expr Fn .truth → Statement Fn

def Statement.list (statements : List (Statement Fn)) : Statement Fn := statements.foldr .sequence .nothing

/-- All bindings from a block are restored on every transfer of control. -/
def Statement.eval (functions : Calls Fn) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (next returned exited : Locals → α) : Statement Fn → α
  | .nothing | .annotate _ => next locals
  | .returned => returned locals
  | .exited => exited locals
  | .exitWhen test => if test.eval functions locals then exited locals else next locals
  | .assign target value => next (target.set functions locals (value.eval functions locals))
  | .resize kind info count => next (info.set functions locals
      (kind.resize backing locals (info.expression.eval functions locals) (count.eval functions locals)))
  | .call procedure => next (procedure.eval functions procedures locals)
  | .sequence first rest => first.eval functions procedures backing locals
      (fun updated => rest.eval functions procedures backing updated next returned exited) returned exited
  | .choose test yes no =>
      if test.eval functions locals then yes.eval functions procedures backing locals next returned exited
      else no.eval functions procedures backing locals next returned exited
  | .block declarations body =>
      let restore := Declarations.restore declarations locals
      body.eval functions procedures backing (declarations.foldl (Declaration.eval functions) locals)
        (next ∘ restore) (returned ∘ restore) (exited ∘ restore)

mutual
def Statement.render (names : FunctionNames Fn) : Statement Fn → List String
  | .nothing => []
  | .assign target value => target.expression.render names ++ [":="] ++ value.render names ++ [";"]
  | .resize kind info count =>
      (Expr.field kind.count info.expression).render names ++ [":="] ++ count.render names ++ [";"]
  | .call primitive => primitive.render names
  | .returned => ["return",";"]
  | .exited => ["exit",";"]
  | .exitWhen test => ["exit","when"] ++ test.render names ++ [";"]
  | .annotate annotation => annotation.render names
  | .sequence first rest => first.render names ++ rest.render names
  | .choose test yes no => ["if"] ++ test.render names ++ ["then"] ++ yes.render names ++
      no.renderElse names ++ ["end","if",";"]
  | .block declarations body => ["declare"] ++ declarations.flatMap (Declaration.render names) ++
      ["begin"] ++ body.render names ++ ["end",";"]
def Statement.renderElse (names : FunctionNames Fn) : Statement Fn → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names
  | statement => ["else"] ++ statement.render names
end

def Statement.wellFormed (names : FunctionNames Fn) (insideLoop : Bool) : Statement Fn → Bool
  | .nothing | .returned => true
  | .exited => insideLoop
  | .exitWhen test => insideLoop && test.logical && test.wellFormed names
  | .assign target value => target.expression.wellFormed names && value.expression && value.wellFormed names
  | .resize _ info count => info.expression.prefix && info.expression.wellFormed names &&
      count.expression && count.wellFormed names
  | .call primitive => primitive.wellFormed names
  | .annotate annotation => annotation.wellFormed names
  | .sequence first rest => first.wellFormed names insideLoop && rest.wellFormed names insideLoop
  | .choose test yes no => test.logical && test.wellFormed names &&
      yes.wellFormed names insideLoop && no.wellFormed names insideLoop
  | .block declarations body => decide (declarations.flatMap Declaration.names).Nodup &&
      declarations.all (Declaration.wellFormed names) && body.wellFormed names insideLoop

def Statement.scoped (scope : Scope) (writable : List String) : Statement Fn → Bool
  | .nothing | .returned | .exited => true
  | .exitWhen test => test.scoped scope
  | .annotate annotation => annotation.allExpressions (fun value => value.scoped scope)
  | .assign target value => decide (target.root ∈ writable) && target.expression.scoped scope && value.scoped scope
  | .resize _ info count => decide (info.root ∈ writable) && info.expression.scoped scope && count.scoped scope
  | .call primitive => primitive.scoped scope writable
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .block declarations body =>
      let inner := Declarations.scan scope writable declarations
      inner.1 && body.scoped inner.2.1 inner.2.2

def Statement.namedCorrect (parameters : FunctionParameters Fn) : Statement Fn → Bool
  | .nothing | .returned | .exited => true
  | .exitWhen test => test.namedCorrect parameters
  | .annotate annotation => annotation.allExpressions (fun value => value.namedCorrect parameters)
  | .assign target value => target.expression.namedCorrect parameters && value.namedCorrect parameters
  | .resize _ info count => info.expression.namedCorrect parameters && count.namedCorrect parameters
  | .call primitive => primitive.allExpressions (fun value => value.namedCorrect parameters)
  | .sequence first rest => first.namedCorrect parameters && rest.namedCorrect parameters
  | .choose test yes no => test.namedCorrect parameters && yes.namedCorrect parameters && no.namedCorrect parameters
  | .block declarations body => declarations.all (Declaration.namedCorrect parameters) && body.namedCorrect parameters

inductive Transfer
  | next (locals : Locals)
  | returned (locals : Locals)
  | exited (locals : Locals)

def Statement.step (statement : Statement Fn) (functions : Calls Fn) (procedures : ProcedureCalls)
    (backing : Backing) (locals : Locals) : Transfer :=
  statement.eval functions procedures backing locals .next .returned .exited

/-- The final step retains both kinds of loop exit: a procedure return skips
the post-loop statements, while an Ada exit continues with them. -/
inductive LoopExec (step : Locals → Transfer) : Locals → Transfer → Prop
  | returned {before after} (last : step before = .returned after) : LoopExec step before (.returned after)
  | exited {before after} (last : step before = .exited after) : LoopExec step before (.exited after)
  | next {before following result} (first : step before = .next following)
      (rest : LoopExec step following result) : LoopExec step before result

structure Body (Fn : Ty → Type) where
  name : String
  declarations : List (Declaration Fn)
  entry : Statement Fn
  guarded : Option (Expr Fn .truth × Statement Fn)
  iteration : Statement Fn
  finish : Statement Fn

def Body.render (names : FunctionNames Fn) (body : Body Fn) : List String :=
  let loopTokens := ["loop"] ++ body.iteration.render names ++ ["end","loop",";"]
  let middle := match body.guarded with
    | none => loopTokens
    | some (test, before) => ["if"] ++ test.render names ++ ["then"] ++ before.render names ++
        loopTokens ++ ["end","if",";"]
  body.declarations.flatMap (Declaration.render names) ++ ["begin"] ++ body.entry.render names ++
    middle ++ body.finish.render names ++ ["end", body.name, ";"]

def Body.wellFormed (names : FunctionNames Fn) (body : Body Fn) : Bool :=
  identifier body.name && decide (body.declarations.flatMap Declaration.names).Nodup &&
    body.declarations.all (Declaration.wellFormed names) &&
    body.entry.wellFormed names false && body.iteration.wellFormed names true &&
    body.finish.wellFormed names false &&
    body.guarded.all (fun (test, before) => test.logical && test.wellFormed names && before.wellFormed names false)

def Body.scoped (scope : Scope) (writable : List String) (body : Body Fn) : Bool :=
  let inside := Declarations.scan scope writable body.declarations
  let statementScoped := fun statement : Statement Fn => statement.scoped inside.2.1 inside.2.2
  inside.1 && statementScoped body.entry && statementScoped body.iteration && statementScoped body.finish &&
    body.guarded.all (fun (test, before) => test.scoped inside.2.1 && statementScoped before)

def Body.namedCorrect (parameters : FunctionParameters Fn) (body : Body Fn) : Bool :=
  body.declarations.all (Declaration.namedCorrect parameters) && body.entry.namedCorrect parameters &&
    body.iteration.namedCorrect parameters && body.finish.namedCorrect parameters &&
    body.guarded.all (fun (test, before) => test.namedCorrect parameters && before.namedCorrect parameters)

/-- Complete procedure execution on original incoming local storage. The caller
can observe the in-out/out parameters at every early return. -/
def Body.Exec (body : Body Fn) (functions : Calls Fn) (procedures : ProcedureCalls) (backing : Backing)
    (locals : Locals) (result : Locals → Prop) : Prop :=
  let finish := fun current => body.finish.eval functions procedures backing current result result (fun _ => False)
  let runLoop := fun current => ∃ terminal, LoopExec (body.iteration.step functions procedures backing) current terminal ∧
      match terminal with
      | .returned stored => result stored
      | .exited stored => finish stored
      | .next _ => False
  let middle := fun current => match body.guarded with
    | none => runLoop current
    | some (test, before) => if test.eval functions current then
        before.eval functions procedures backing current runLoop result (fun _ => False)
      else finish current
  body.entry.eval functions procedures backing (body.declarations.foldl (Declaration.eval functions) locals)
    middle result (fun _ => False)

end Silver.ApplicationPackageDeclarations.Control
