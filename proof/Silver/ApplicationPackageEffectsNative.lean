module

public import Silver.ApplicationPackageEffectsModel
public import Silver.ApplicationNativeCommands

@[expose] public section

namespace Silver.ApplicationPackageEffects.Native
open Compose Predicate ApplicationNative

inductive Function : Ty → Type
  | validName : Function (.arrow .source (.arrow .nameSpan .truth))
  | scalarLookup : Function (.arrow .source (.arrow .scalars (.arrow .number (.arrow .number .number))))
  | booleanLookup : Function (.arrow .source (.arrow .booleans (.arrow .number (.arrow .number .number))))
  | skip : Function (.arrow .source (.arrow .number .number))
  | nameAfter : Function (.arrow .source (.arrow .number .number))
  | lookupState : Function (.arrow .source (.arrow .metadata (.arrow .nameSpan .number)))
  | actualNameFree : Function (.arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth)))))
  | visibleState : Function (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number .truth))))

def functionNames : FunctionNames Function
  | _, .validName => ["packages", ".", "valid_name"]
  | _, .scalarLookup => ["scalar_expressions", ".", "lookup"]
  | _, .booleanLookup => ["lookup_boolean"]
  | _, .skip => ["skip_at"]
  | _, .nameAfter => ["name_after"]
  | _, .lookupState => ["packages", ".", "lookup_state"]
  | _, .actualNameFree => ["actual_name_free"]
  | _, .visibleState => ["visible_state"]

def callsOf (calls : ApplicationPackageEffects.Calls) : ApplicationNative.Calls Function
  | _, .validName => calls.validName
  | _, .scalarLookup => calls.scalarLookup
  | _, .booleanLookup => calls.booleanLookup
  | _, .skip => calls.skip
  | _, .nameAfter => calls.nameAfter
  | _, .lookupState => calls.lookupState
  | _, .actualNameFree => calls.actualNameFree
  | _, .visibleState => ApplicationPackageEffects.visibleState calls

abbrev E := Expr Function
abbrev P := Place Function

def text : E .source := .variable "text"
def context : E .parseContext := .variable "context"
def info : E .metadata := .variable "info"
def name : E .nameSpan := .variable "name"
def indexValue : E .number := .variable "index"
def first : E .number := .variable "first"
def after : E .number := .variable "after"
def scalar : E .number := .variable "scalar"
def flag : E .number := .variable "flag"
def found : E .number := .variable "found"
def result : P .stateSet := .variable "result"

def app2 (f : Function (.arrow a (.arrow b c))) (x : E a) (y : E b) : E c :=
  .app (.app (.function f) x) y

def app3 (f : Function (.arrow a (.arrow b (.arrow c d)))) (x : E a) (y : E b) (z : E c) : E d :=
  .app (app2 f x y) z

def app4 (f : Function (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (x : E a) (y : E b) (z : E c) (w : E d) : E e := .app (app3 f x y z) w

def app5 (f : Function (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e r))))))
    (x : E a) (y : E b) (z : E c) (w : E d) (v : E e) : E r := .app (app4 f x y z w) v

def scalarNames : E .scalars := .field .contextScalarNames context
def booleanNames : E .booleans := .field .contextBooleanNames context

def visibleBody : Body Function .truth where
  name := "visible_state"
  declarations := [
    ⟨.nameSpan, "name", ["packages", ".", "name_span"], true,
      some (.field .declarationName (.index .state info indexValue)), [], none⟩,
    ⟨.number, "scalar", ["scalar_expressions", ".", "binding_count"], false, none, [], none⟩,
    ⟨.number, "flag", ["boolean_count"], false, none, [], none⟩]
  commands := .list [
    .choose (.orElse (.gt indexValue (.field .stateCount info)) (.not (app2 .validName text name)))
      (.returned (.truth false)) .nothing,
    .assign (.variable "scalar")
      (app4 .scalarLookup text scalarNames (.field .nameFirst name) (.field .nameAfter name)),
    .choose (.kindEq (.field .declarationKind (.index .state info indexValue)) (.scalarKind .integer))
      (.returned (.andThen (.andThen (.ne scalar (.number 0))
        (.eq (.field .scalarFirst (.index .scalar scalarNames scalar)) (.field .nameFirst name)))
        (.eq (.field .scalarAfter (.index .scalar scalarNames scalar)) (.field .nameAfter name)))) .nothing,
    .choose (.ne scalar (.number 0)) (.returned (.truth false)) .nothing,
    .assign (.variable "flag")
      (app4 .booleanLookup text booleanNames (.field .nameFirst name) (.field .nameAfter name)),
    .returned (.andThen (.andThen (.ne flag (.number 0))
      (.eq (.field .booleanFirst (.index .boolean booleanNames flag)) (.field .nameFirst name)))
      (.eq (.field .booleanAfter (.index .boolean booleanNames flag)) (.field .nameAfter name)))]

def targetBody : Body Function .number where
  name := "state_target"
  declarations := [
    ⟨.number, "first", ["literal_position"], true, some (app2 .skip text (.variable "position")), [], none⟩,
    ⟨.number, "last", ["literal_position"], true, some (app2 .nameAfter text first), [], none⟩,
    ⟨.number, "found", ["packages", ".", "state_id"], true,
      some (app3 .lookupState text info (.nameSpan first (.variable "last"))), [], none⟩]
  commands := .returned (.group (.ite
    (.andThen (.ne found (.number 0)) (app4 .visibleState text context info found)) found (.number 0)))

def readsLoopBody : Command Function .stateSet :=
  .sequence
    (.invariant (.forAllStates "s" (.group (.conditionalTrue
      (.gt (.variable "s") (.field .stateCount info))
      (.not (.index .stateBit result.expression (.variable "s")))))))
    (.choose (app4 .visibleState text context info (.variable "i"))
      (.assign (.index .stateBit result (.variable "i"))
        (.not (app5 .actualNameFree text first after
          (.field .nameFirst (.field .declarationName (.index .state info (.variable "i"))))
          (.field .nameAfter (.field .declarationName (.index .state info (.variable "i")))))))
      .nothing)

def readsBody : Body Function .stateSet where
  name := "state_reads"
  declarations := [⟨.stateSet, "result", ["packages", ".", "state_set"], false, some .emptyStateSet, [], none⟩]
  commands := .list [
    .choose (.orElse (.eq first (.number 0)) (.le after first)) (.returned result.expression) .nothing,
    .forRange "i" (.number 1) (.field .stateCount info) readsLoopBody,
    .returned result.expression]

def commonScope : Scope := [(.source,"text"),(.parseContext,"context"),(.metadata,"info")]

theorem effects_wellFormed : visibleBody.wellFormed functionNames = true ∧
    targetBody.wellFormed functionNames = true ∧ readsBody.wellFormed functionNames = true := by
  decide +kernel

theorem effects_scoped : visibleBody.scoped ((.number,"index") :: commonScope) = true ∧
    targetBody.scoped ((.number,"position") :: commonScope) = true ∧
    readsBody.scoped ((.number,"first") :: (.number,"after") :: commonScope) = true := by
  decide +kernel

end Silver.ApplicationPackageEffects.Native
