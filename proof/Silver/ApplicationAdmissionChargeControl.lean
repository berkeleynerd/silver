module

public import Silver.ComposeExpressions

@[expose] public section

/-! The single plain loop in Charge_Unit, over the existing typed Compose
expressions. Uninitialized storage is retained, and return observes both out
parameters. This local fragment follows the declaration-reader loop control. -/
namespace Silver.ApplicationAdmission.Charge.Control
open Compose.Expressions

structure Declaration where
  type : Ty
  names : List String
  typeName : List String
  initial : Option (Expr type) := none

def Declaration.render (item : Declaration) : List String :=
  List.flatten (item.names.map (fun name => [name]) |>.intersperse [","]) ++
    [":"] ++ item.typeName ++
    (match item.initial with | none => [] | some value => [":="] ++ value.render) ++ [";"]

def Declaration.eval (calls : Calls) (locals : Locals) (item : Declaration) : Locals :=
  match item.initial with
  | none => locals
  | some value => item.names.foldl (fun store name => store.set item.type name (value.eval calls locals)) locals

def Declaration.validType : Ty → List String → Bool
  | .number, name => decide (name ∈ [["cursor"], ["literal_position"]])
  | .scalarLiteral, name => name == ["silver_scalar_literals", ".", "literal_result"]
  | .value, name => name == ["value_result"]
  | .truth, name => name == ["boolean"]
  | _, _ => false

def Declaration.checked (scope : Scope) (item : Declaration) : Bool :=
  !item.names.isEmpty && item.names.all (fun name => !name.isEmpty) &&
    Declaration.validType item.type item.typeName && item.initial.all (fun value =>
      value.expression && value.wellFormed && value.scoped scope)

def Declaration.scope (scope : Scope) (item : Declaration) : Scope :=
  item.names.map (fun name => (name, item.type)) ++ scope

def declarationsChecked : Scope → List Declaration → Bool
  | _, [] => true
  | scope, item :: rest => item.checked scope && declarationsChecked (item.scope scope) rest

inductive Annotation
  | invariant : Expr .truth → Annotation
  | increases : Expr .number → Annotation

def Annotation.render : Annotation → List String
  | .invariant value => ["pragma", "loop_invariant", "("] ++ value.render ++ [")", ";"]
  | .increases value => ["pragma", "loop_variant", "(", "increases", "=>"] ++ value.render ++ [")", ";"]

def Annotation.checked (scope : Scope) : Annotation → Bool
  | .invariant value => value.logical && value.wellFormed && value.scoped scope
  | .increases value => value.simple && value.wellFormed && value.scoped scope

inductive Statement
  | nothing
  | assign (name : String) : Expr ty → Statement
  | sequence : Statement → Statement → Statement
  | choose : Expr .truth → Statement → Statement → Statement
  | annotate : Annotation → Statement
  | returned

def Statement.list (items : List Statement) : Statement := items.foldr .sequence .nothing

def Statement.eval (calls : Calls) (locals : Locals) (next returned : Locals → α) : Statement → α
  | .nothing | .annotate _ => next locals
  | .assign name value => next (locals.set _ name (value.eval calls locals))
  | .sequence first rest => first.eval calls locals (fun store => rest.eval calls store next returned) returned
  | .choose test yes no => if test.eval calls locals then yes.eval calls locals next returned else no.eval calls locals next returned
  | .returned => returned locals

mutual
def Statement.render : Statement → List String
  | .nothing => []
  | .assign name value => [name, ":="] ++ value.render ++ [";"]
  | .sequence first rest => first.render ++ rest.render
  | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
  | .annotate annotation => annotation.render
  | .returned => ["return", ";"]
def Statement.renderElse : Statement → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
  | other => ["else"] ++ other.render
end

def Statement.checked (scope : Scope) (writable : List String) : Statement → Bool
  | .nothing | .returned => true
  | .assign (ty := ty) name value => decide (name ∈ writable) && scope.contains name ty &&
      value.expression && value.wellFormed && value.scoped scope
  | .sequence first rest => first.checked scope writable && rest.checked scope writable
  | .choose test yes no => test.logical && test.wellFormed && test.scoped scope &&
      yes.checked scope writable && no.checked scope writable
  | .annotate annotation => annotation.checked scope

inductive Transfer
  | next (locals : Locals)
  | returned (locals : Locals)

def Statement.step (body : Statement) (calls : Calls) (locals : Locals) : Transfer :=
  body.eval calls locals .next .returned

inductive LoopExec (step : Locals → Transfer) : Locals → Locals → Prop
  | returned {before after} : step before = .returned after → LoopExec step before after
  | next {before following after} : step before = .next following → LoopExec step following after → LoopExec step before after

theorem LoopExec.unique {step : Locals → Transfer} {before left right : Locals}
    (first : LoopExec step before left) (second : LoopExec step before right) : left = right := by
  induction first with
  | returned finish =>
    cases second with
    | returned other => exact Transfer.returned.inj (finish.symm.trans other)
    | next other _ => simp only [finish, reduceCtorEq] at other
  | next advanced _ induction =>
    cases second with
    | returned other => simp only [advanced, reduceCtorEq] at other
    | next other rest =>
      have same := Transfer.next.inj (advanced.symm.trans other)
      subst same
      exact induction rest

structure Body where
  name : String
  declarations : List Declaration
  entry : Statement
  iteration : Statement

def Body.render (body : Body) : List String :=
  body.declarations.flatMap Declaration.render ++ ["begin"] ++ body.entry.render ++
    ["loop"] ++ body.iteration.render ++ ["end", "loop", ";", "end", body.name, ";"]

def Body.checked (body : Body) (scope : Scope) (writable : List String) : Bool :=
  let names := body.declarations.flatMap Declaration.names
  let inside := body.declarations.foldl Declaration.scope scope
  decide (names ++ scope.map Prod.fst).Nodup && declarationsChecked scope body.declarations &&
    body.entry.checked inside (names ++ writable) && body.iteration.checked inside (names ++ writable)

def Body.Exec (body : Body) (calls : Calls) (locals : Locals) (result : Locals → Prop) : Prop :=
  body.entry.eval calls (body.declarations.foldl (Declaration.eval calls) locals)
    (fun entry => ∃ after, LoopExec (body.iteration.step calls) entry after ∧ result after) result

end Silver.ApplicationAdmission.Charge.Control
