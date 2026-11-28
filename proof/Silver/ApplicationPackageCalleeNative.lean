module

public import Silver.ApplicationPackageCallsModel
public import Silver.ApplicationNativeDeclarationLaws

@[expose] public section

/-! Complete typed Package_Callee body. All imported routines remain explicit;
the denotation quantifies over arbitrary initial locals, including the native
uninitialized Callee slot. The assigned Reference and Callee values follow the
actual declaration and command order. -/
namespace Silver.ApplicationPackageCalls.Native
open ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

inductive Function : Ty → Type
  | reference : Function (.arrow .source (.arrow .number .reference))
  | scalarLookup : Function (.arrow .source (.arrow .scalars (.arrow .number (.arrow .number .number))))
  | booleanLookup : Function (.arrow .source (.arrow .booleans (.arrow .number (.arrow .number .number))))
  | sameName : Function (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | lookupRoutine : Function (.arrow .source (.arrow .metadata (.arrow .nameSpan .number)))

def functionNames : FunctionNames Function
  | _, .reference => ["scalar_expressions", ".", "read_reference"]
  | _, .scalarLookup => ["scalar_expressions", ".", "lookup"]
  | _, .booleanLookup => ["lookup_boolean"]
  | _, .sameName => ["packages", ".", "same_name"]
  | _, .lookupRoutine => ["packages", ".", "lookup_routine"]

def imported (calls : ApplicationPackageCalls.Calls) : ApplicationNative.Calls Function
  | _, .reference => calls.reference
  | _, .scalarLookup => calls.scalarLookup
  | _, .booleanLookup => calls.booleanLookup
  | _, .sameName => calls.sameName
  | _, .lookupRoutine => fun text info name => calls.lookupRoutine text info name true

abbrev E := Expr Function

def apply2 (fn : Function (.arrow a (.arrow b c))) (x : E a) (y : E b) : E c :=
  .app (.app (.function fn) x) y

def apply3 (fn : Function (.arrow a (.arrow b (.arrow c d))))
    (x : E a) (y : E b) (z : E c) : E d :=
  .app (.app (.app (.function fn) x) y) z

def apply4 (fn : Function (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (w : E a) (x : E b) (y : E c) (z : E d) : E e :=
  .app (.app (.app (.app (.function fn) w) x) y) z

def text : E .source := .variable "text"
def context : E .parseContext := .variable "context"
def info : E .metadata := .variable "info"
def position : E .number := .variable "position"
def kind : E .routineKind := .variable "kind"
def reference : E .reference := .variable "reference"
def callee : E .number := .variable "callee"

def referenceName : E .nameSpan :=
  .nameSpan (.field .referenceFirst reference) (.field .referenceAfter reference)

def firstRejected : E .truth := .orElse
  (.gt (.field .infoCompleted info) (.field .routineCount info))
  (.eq (.field .referenceAfter reference) (.number 0))

def pureRejected : E .truth := .orElse
  (.orElse (.ne (.field .referenceQualifierFirst reference) (.number 0))
    (.ne (apply4 .scalarLookup text (.field .contextScalarNames context)
      (.field .referenceFirst reference) (.field .referenceAfter reference)) (.number 0)))
  (.ne (apply4 .booleanLookup text (.field .contextBooleanNames context)
    (.field .referenceFirst reference) (.field .referenceAfter reference)) (.number 0))

def otherPackage : E .truth := .not (apply3 .sameName text
  (.nameSpan (.field .referenceQualifierFirst reference) (.field .referenceQualifierAfter reference))
  (.nameSpan (.field .infoNameFirst info) (.field .infoNameAfter info)))

def calleeValue : E .number := .group (.ite
  (.andThen (.ne callee (.number 0))
    (.routineEq (.field .routineKind (.index .routine info callee)) kind))
  callee (.number 0))

def calleeCommands : Command Function .number := .list [
  .choose firstRejected (.returned (.number 0)) .nothing,
  .choose (.field .contextPure context)
    (.choose pureRejected (.returned (.number 0)) .nothing)
    (.choose otherPackage (.returned (.number 0)) .nothing),
  .assign (.variable "callee") (apply3 .lookupRoutine text info referenceName),
  .returned calleeValue]

def calleeBody : Body Function .number where
  name := "package_callee"
  declarations := [
    {type := .reference, name := "reference",
      typeName := ["scalar_expressions", ".", "name_reference"], constant := true,
      initial := some (apply2 .reference text position)},
    {type := .number, name := "callee", typeName := ["packages", ".", "routine_count_type"],
      initial := none}]
  commands := calleeCommands

theorem callee_wellFormed : calleeBody.wellFormed functionNames = true := by decide +kernel

theorem callee_scoped : calleeBody.scoped
    [(.source, "text"), (.parseContext, "context"), (.metadata, "info"),
     (.number, "position"), (.routineKind, "kind")] = true := by decide +kernel

theorem callee_denotation (calls : ApplicationPackageCalls.Calls) (initial : Locals) :
    calleeBody.eval (imported calls) initial =
      packageCallee calls (initial .source "text") (initial .parseContext "context")
        (initial .metadata "info") (initial .number "position") (initial .routineKind "kind") := by
  dsimp only [calleeBody, Body.eval, Declaration.eval, Declaration.names, calleeCommands, Command.list,
    Command.eval, Place.set, Place.expression, firstRejected, pureRejected, otherPackage,
    calleeValue, referenceName, apply2, apply3, apply4, Expr.eval, imported,
    text, context, info, position, kind, reference, callee, Field.get, Index.get,
    Locals.set, packageCallee, List.foldl, List.foldr]
  cases pure : (initial .parseContext "context").pure <;> simp [pure, or_assoc]

end Silver.ApplicationPackageCalls.Native
