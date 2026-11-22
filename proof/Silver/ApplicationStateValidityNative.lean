module

public import Silver.ApplicationNativeCommands
public import Silver.ApplicationPackageFrameValidity
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Executable interpretation of Valid_State. Its imported table predicates are
kept explicit: the equation neither assumes that a state is reachable nor replaces
an executable check by a validity premise. The native field subtypes are handled
separately by StateType. -/
namespace Silver.ApplicationPackageFrames.ValidityNative
open ApplicationNative Compose

inductive Function : Ty → Type
  | nameState : Function (.arrow .source (.arrow .number (.arrow .number .truth)))
  | functions : Function (.arrow .source (.arrow .functions .truth))
  | procedures : Function (.arrow .source (.arrow .procedures .truth))
  | names : Function (.arrow .source (.arrow .names .truth))
  | scalars : Function (.arrow .source (.arrow .scalars .truth))
  | arrays : Function (.arrow .source (.arrow .arrays .truth))
  | subtypes : Function (.arrow .source (.arrow .subtypes .truth))
  | booleans : Function (.arrow .source (.arrow .booleans .truth))
  | mutableBounds : Function (.arrow .scalars .truth)
  | declarationValues : Function (.arrow .scalars (.arrow .number .truth))

def functionNames : FunctionNames Function
  | _, .nameState => ["valid_name_state"]
  | _, .functions => ["functions", ".", "valid_metadata"]
  | _, .procedures => ["procedures", ".", "valid_metadata"]
  | _, .names => ["valid_names"]
  | _, .scalars => ["scalar_expressions", ".", "valid_environment"]
  | _, .arrays => ["array_bindings", ".", "valid_environment"]
  | _, .subtypes => ["valid_subtypes"]
  | _, .booleans => ["valid_booleans"]
  | _, .mutableBounds => ["valid_mutable_bounds"]
  | _, .declarationValues => ["valid_declaration_values"]

def modelCalls : Calls Function
  | _, .nameState => nameStateValid
  | _, .functions => fun text value => decide (FunctionBindings.ValidMetadata text value)
  | _, .procedures => fun text value => decide (ProcedureBindings.ValidMetadata text value)
  | _, .names => stringNamesValid
  | _, .scalars => scalarNamesValid
  | _, .arrays => fun text value => decide (ArrayBindings.ValidNativeEnvironment text value)
  | _, .subtypes => subtypesValid
  | _, .booleans => booleanNamesValid
  | _, .mutableBounds => mutableBoundsValid
  | _, .declarationValues => declarationValuesValid

abbrev E := Expr Function

def text : E .source := .variable "text"
def state : E .state := .variable "state"
def limit : E .number := .add (.sourceLast text) (.number 1)
def scalars : E .scalars := .field .stateScalarNames state

def app2 (f : Function (.arrow a (.arrow b c))) (x : E a) (y : E b) : E c :=
  .app (.app (.function f) x) y

def nameState (first after : Field .state .number) : E .truth :=
  .app (app2 .nameState text (.field first state)) (.field after state)

def validStateBody : E .truth :=
  [ .le (.field .stateContextFirst state) limit,
    nameState .statePackageFirst .statePackageAfter,
    app2 .functions text (.field .stateFunctions state),
    app2 .procedures text (.field .stateProcedures state),
    .le (.field .stateFirstParameter state)
      (.add (.field .functionParameterCount (.field .stateFunctions state)) (.number 1)),
    .le (.field .stateFirstProcedureParameter state)
      (.add (.field .procedureParameterCount (.field .stateProcedures state)) (.number 1)),
    app2 .names text (.field .stateNames state),
    app2 .scalars text scalars,
    app2 .arrays text (.field .stateArrayNames state),
    app2 .subtypes text (.field .stateSubtypeNames state),
    app2 .booleans text (.field .stateBooleanNames state),
    .app (.function .mutableBounds) scalars,
    app2 .declarationValues scalars (.field .scalarCount scalars),
    nameState .stateDynamicFirst .stateDynamicAfter,
    .le (.field .stateTarget state) (.field .nameCount (.field .stateNames state))
  ].foldl .andThen (.le (.field .statePosition state) limit)

def scope : Scope := [(.source, "text"), (.state, "state")]

theorem validState_checked : validStateBody.wellFormed functionNames = true ∧
    validStateBody.scoped scope = true := by decide +kernel

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

theorem validState_meaning (locals : Locals) :
    validStateBody.eval modelCalls locals = stateValid (locals .source "text") (locals .state "state") := by
  rfl

/-- Existing native type bounds plus the executable predicate imply the complete
inherited parser domain. This applies to arbitrary states, not only parser outputs. -/
theorem validState_domain (locals : Locals)
    (typed : StateType (locals .state "state"))
    (accepted : validStateBody.eval modelCalls locals = true) :
    Predicate.OuterReadiness.ValidState (locals .source "text") (locals .state "state") :=
  ApplicationPackageFrames.stateValid_domain typed ((validState_meaning locals) ▸ accepted)

end Silver.ApplicationPackageFrames.ValidityNative
