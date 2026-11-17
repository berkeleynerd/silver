module

public import Silver.PredicateBodyAdmission

@[expose] public section

/-! The metadata selectors read the same accepted outer scan used by admission.
This syntax retains the direct-first selection and the executable wrapper's
local bindings, rather than assuming the returned procedure catalog. -/
namespace Silver.Predicate.ProcedureMetadataNative
open Compose

inductive Reader | model | executable
  deriving DecidableEq, Repr

structure Calls where
  form : Reader → Source → Form → ScanResult
  model : Source → ProcedureBindings.Metadata
  executable : Source → ProcedureBindings.Metadata

abbrev Locals := String → ScanResult

inductive ScanExpr
  | call (reader : Reader) (form : Form)
  | variable (name : String)

def ScanExpr.eval (calls : Calls) (text : Source) (locals : Locals) : ScanExpr → ScanResult
  | .call reader form => calls.form reader text form
  | .variable name => locals name

def formName : Form → String
  | .direct => "direct_form"
  | .argument => "argument_form"

def Reader.name : Reader → String
  | .model => "form_result"
  | .executable => "read_form"

def ScanExpr.render : ScanExpr → List String
  | .call reader form => [reader.name, "(", "source", ",", formName form, ")"]
  | .variable name => [name]

def ScanExpr.scoped (scope : List String) : ScanExpr → Bool
  | .call _ _ => scope.contains "source"
  | .variable name => scope.contains name

inductive Expr
  | empty
  | procedures (scan : ScanExpr)
  | selected (scan : ScanExpr) (yes no : Expr)
  | selectedElseIf (scan : ScanExpr) (yes : Expr) (other : ScanExpr) (otherYes no : Expr)

def Expr.eval (calls : Calls) (text : Source) (locals : Locals) : Expr → ProcedureBindings.Metadata
  | .empty => {}
  | .procedures scan => (scan.eval calls text locals).state.procedures
  | .selected scan yes no =>
      if (scan.eval calls text locals).state.position ≠ 0 then yes.eval calls text locals else no.eval calls text locals
  | .selectedElseIf scan yes other otherYes no =>
      if (scan.eval calls text locals).state.position ≠ 0 then yes.eval calls text locals
      else if (other.eval calls text locals).state.position ≠ 0 then otherYes.eval calls text locals
      else no.eval calls text locals

def acceptedTokens (scan : ScanExpr) : List String :=
  scan.render ++ [".", "state", ".", "position", "/=", "0"]

/-- Every conditional expression is explicitly parenthesized. The remaining
constructors are constants or selected components of call/identifier prefixes. -/
def Expr.render : Expr → List String
  | .empty => ["procedures", ".", "empty_metadata"]
  | .procedures scan => scan.render ++ [".", "state", ".", "procedures"]
  | .selected scan yes no => ["(", "if"] ++ acceptedTokens scan ++
      ["then"] ++ yes.render ++ ["else"] ++ no.render ++ [")"]
  | .selectedElseIf scan yes other otherYes no => ["(", "if"] ++ acceptedTokens scan ++
      ["then"] ++ yes.render ++ ["elsif"] ++ acceptedTokens other ++
      ["then"] ++ otherYes.render ++ ["else"] ++ no.render ++ [")"]

def Expr.scoped (scope : List String) : Expr → Bool
  | .empty => true
  | .procedures scan => scan.scoped scope
  | .selected scan yes no => scan.scoped scope && yes.scoped scope && no.scoped scope
  | .selectedElseIf scan yes other otherYes no => scan.scoped scope && yes.scoped scope &&
      other.scoped scope && otherYes.scoped scope && no.scoped scope

inductive Command
  | returned (value : Expr)
  | letScan (name : String) (value : ScanExpr) (body : Command)
  | beginBody (body : Command)
  | block (body : Command)
  | guard (scan : ScanExpr) (value : Expr) (body : Command)

def Command.eval (calls : Calls) (text : Source) (locals : Locals) : Command → ProcedureBindings.Metadata
  | .returned value => value.eval calls text locals
  | .letScan name value body => body.eval calls text
      (fun key => if key = name then value.eval calls text locals else locals key)
  | .beginBody body | .block body => body.eval calls text locals
  | .guard scan value body => if (scan.eval calls text locals).state.position ≠ 0 then
      value.eval calls text locals else body.eval calls text locals

def Command.render : Command → List String
  | .returned value => ["return"] ++ value.render ++ [";"]
  | .letScan name value body => [name, ":", "constant", "scan_result", ":="] ++ value.render ++ [";"] ++ body.render
  | .beginBody body => ["begin"] ++ body.render
  | .block body => ["declare"] ++ body.render ++ ["end", ";"]
  | .guard scan value body => ["if"] ++ acceptedTokens scan ++ ["then", "return"] ++ value.render ++
      [";", "end", "if", ";"] ++ body.render

def Command.scoped (scope : List String) : Command → Bool
  | .returned value => value.scoped scope
  | .letScan name value body => !scope.contains name && value.scoped scope && body.scoped (name :: scope)
  | .beginBody body | .block body => body.scoped scope
  | .guard scan value body => scan.scoped scope && value.scoped scope && body.scoped scope

def modelBody : Expr :=
  .selectedElseIf (.call .model .direct) (.procedures (.call .model .direct))
    (.call .model .argument) (.procedures (.call .model .argument)) .empty

def executableBody : Command :=
  .letScan "direct" (.call .executable .direct) <|
    .beginBody <| .guard (.variable "direct") (.procedures (.variable "direct")) <|
    .block <| .letScan "argument" (.call .executable .argument) <|
    .beginBody <| .returned <|
      .selected (.variable "argument") (.procedures (.variable "argument")) .empty

def select (reader : Source → Form → ScanResult) (text : Source) : ProcedureBindings.Metadata :=
  if (reader text .direct).state.position ≠ 0 then (reader text .direct).state.procedures
  else if (reader text .argument).state.position ≠ 0 then (reader text .argument).state.procedures
  else {}

def procedureModel (text : Source) : ProcedureBindings.Metadata := select formResult text

theorem model_denotation (calls : Calls) (text : Source) (locals : Locals) :
    modelBody.eval calls text locals = select (calls.form .model) text := rfl

theorem executable_denotation (calls : Calls) (text : Source) (locals : Locals) :
    executableBody.eval calls text locals = select (calls.form .executable) text := by
  simp only [executableBody, Command.eval, ScanExpr.eval, Expr.eval, select, ↓reduceIte]

theorem checked_scope : modelBody.scoped ["source"] = true ∧ executableBody.scoped ["source"] = true := by
  decide +kernel

structure Equations (calls : Calls) : Prop where
  model : ∀ text, calls.model text = modelBody.eval calls text (fun _ => initialScan)
  executable : ∀ text, calls.executable text = executableBody.eval calls text (fun _ => initialScan)

/-- Form_Result is interpreted by the existing outer scanner chain. Read_Form
has the exact source-checked Static postcondition equating it to Form_Result;
the complete native proof discharges that contract on every input. -/
structure FormImports (calls : Calls) : Prop where
  model : ∀ text form, calls.form .model text form = formResult text form
  executable : ∀ text form, calls.form .executable text form = calls.form .model text form

theorem interpreted_model (calls : Calls) (equations : Equations calls) (imports : FormImports calls)
    (text : Source) : calls.model text = procedureModel text := by
  rw [equations.model, model_denotation]
  unfold procedureModel select
  simp only [imports.model]

theorem interpreted_executable (calls : Calls) (equations : Equations calls) (imports : FormImports calls)
    (text : Source) : calls.executable text = procedureModel text := by
  rw [equations.executable, executable_denotation]
  unfold procedureModel select
  simp only [imports.executable, imports.model]

end Silver.Predicate.ProcedureMetadataNative
