module

public import Silver.ApplicationPackageBodiesControl
public import Silver.ApplicationPackageBodiesModel

@[expose] public section

namespace Silver.ApplicationPackageBodies.Tail
open ApplicationNative ApplicationPackages

inductive Fn : Ty → Type
  | atStop : Fn (.arrow .source (.arrow .number (.arrow .bodyStop .truth)))
  | statement : Fn (.arrow .source (.arrow .parseContext (.arrow .appScan (.arrow .metadata (.arrow .functions (.arrow .procedures .appScan))))))
  | invalid : Fn (.arrow .appScan .appScan)
  | valid : Fn (.arrow .source (.arrow .parseContext (.arrow .bodyScan .truth)))

def names : FunctionNames Fn
  | _, .atStop => ["at_body_stop"] | _, .statement => ["application_statement"]
  | _, .invalid => ["invalid_application"] | _, .valid => ["valid_body"]

abbrev ValidBody := Source → Predicate.ParseContext → Predicate.BodyScan → Bool

def functions (calls : TailCalls) (valid : ValidBody) : Calls Fn
  | _, .atStop => calls.atBodyStop | _, .statement => calls.applicationStatement
  | _, .invalid => invalidApplication | _, .valid => valid

abbrev C := Statements.Command Fn
abbrev E := Expr Fn
abbrev text : E .source := .variable "text"
abbrev context : E .parseContext := .variable "context"
abbrev input : E .appScan := .variable "input"
abbrev result : E .appScan := .variable "result"
abbrev scan : E .bodyScan := .field .applicationScan result
abbrev position : E .number := .field .scanPosition scan
abbrev invalid : C := .returned (.app (.function .invalid) result)
abbrev step : E .appScan := .app (.app (.app (.app (.app (.app (.function .statement) text) context) result)
  (.variable "info")) (.variable "catalog")) (.variable "procedure_catalog")
abbrev test : E .truth := .andThen (.ne position (.number 0))
  (.not (.app (.app (.app (.function .atStop) text) position) (.variable "stop")))

def declarations : List (Declaration Fn) := [
  {type := .appScan, name := "result", typeName := ["application_scan"], constraint := some (.property .appScanCount input),
   initial := some input},
  {type := .number, name := "before", typeName := ["literal_position"], initial := none},
  {type := .truth, name := "seen", typeName := ["boolean"], initial := some (.truth false)}]

def iteration : C := .list [
  .invariant (.app (.app (.app (.function .valid) text) context) scan),
  .invariant (.ge position (.field .scanPosition (.field .applicationScan input))),
  .invariant (.truthEq (.field .applicationAllowProcedureCalls result) (.field .applicationAllowProcedureCalls input)),
  .increases position,
  .assign (.variable "before") position,
  .assign (.variable "result") step,
  .choose (.le position (.variable "before")) invalid .nothing,
  .assign (.variable "seen") (.truth true)]

def ending : C := .sequence
  (.choose (.orElse (.eq position (.number 0)) (.group (.andThen (.variable "require_one") (.not (.variable "seen")))))
    invalid .nothing)
  (.returned result)

def body : Statements.Body Fn := ⟨"application_tail", declarations, .sequence (.whileLoop test iteration) ending⟩

abbrev parameters : FunctionParameters Fn := fun _ => []
abbrev scope : Scope := [(.source, "text"), (.parseContext, "context"), (.appScan, "input"),
  (.metadata, "info"), (.bodyStop, "stop"), (.truth, "require_one"), (.functions, "catalog"), (.procedures, "procedure_catalog")]

theorem checked_tree : body.checked names parameters scope = true := by decide +kernel

end Silver.ApplicationPackageBodies.Tail
