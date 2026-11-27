module

public import Silver.ApplicationStateValidityTables
public import Silver.FunctionBindingsSourceBridge
public import Silver.ProcedureBindingsSourceBridge
public import Silver.ArrayBindingsSourceBridge

@[expose] public section

namespace Silver.ApplicationPackageFrames.ValidityNative
open ApplicationNative Compose

/-- Bounds supplied by the native metadata/environment field types. These are
not declaration validity or a successful parser history. -/
structure ImportedTypes (state : ParserState) : Prop where
  functions : FunctionBindings.Native.MetadataType state.functions
  procedures : ProcedureBindings.Native.MetadataType state.procedures
  arrays : ArrayBindings.Native.EnvironmentType state.arrayNames

structure Imports where
  functions : FunctionBindings.Native.Calls
  functionSource : FunctionBindings.SourceBridge.InterpretedSource functions
  procedures : ProcedureBindings.Native.Calls
  procedureSource : ProcedureBindings.SourceBridge.InterpretedSource procedures
  arrays : ArrayBindings.Native.Calls
  arraySource : ArrayBindings.SourceBridge.InterpretedSource arrays

def tableLocals (text : Source) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  Locals.set (Locals.set (fun (kind : Ty) (_ : String) => kind.default)
    .source "text" text) ty name value

def importedCalls (imports : Imports) : Calls Function
  | _, .functions => imports.functions.validMetadata
  | _, .procedures => imports.procedures.validMetadata
  | _, .arrays => imports.arrays.validEnvironment
  | _, .nameState => nameStateValid
  | _, .names => fun text names => ValidityTables.namesBody.eval ValidityTables.modelCalls
      (tableLocals text .names "names" names)
  | _, .scalars => fun text names => ValidityTables.scalarBody.eval ValidityTables.modelCalls
      (tableLocals text .scalars "names" names)
  | _, .booleans => fun text names => ValidityTables.booleanBody.eval ValidityTables.modelCalls
      (tableLocals text .booleans "booleans" names)
  | _, .subtypes => fun text names => ValidityTables.subtypeBody.eval ValidityTables.modelCalls
      (tableLocals text .subtypes "subtypes" names)
  | _, .mutableBounds => fun names => ValidityTables.mutableBody.eval ValidityTables.modelCalls
      (tableLocals [] .scalars "scalar_names" names)
  | _, .declarationValues => fun names count => ValidityTables.valuesBody.eval ValidityTables.modelCalls
      ((tableLocals [] .scalars "scalar_names" names).set .number "count" count)

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem importedCalls_names (imports : Imports) (text : Source) (names : BindingEnvironment) :
    importedCalls imports _ .names text names = stringNamesValid text names := by
  change ValidityTables.namesBody.eval ValidityTables.modelCalls _ = _
  rw [ValidityTables.names_meaning]
  simp [tableLocals, Locals.set]

theorem importedCalls_scalars (imports : Imports) (text : Source) (names : ScalarExpression.Environment) :
    importedCalls imports _ .scalars text names = scalarNamesValid text names := by
  change ValidityTables.scalarBody.eval ValidityTables.modelCalls _ = _
  rw [ValidityTables.scalar_meaning]
  simp [tableLocals, Locals.set]

theorem importedCalls_booleans (imports : Imports) (text : Source) (names : BooleanBindings.Environment) :
    importedCalls imports _ .booleans text names = booleanNamesValid text names := by
  change ValidityTables.booleanBody.eval ValidityTables.modelCalls _ = _
  rw [ValidityTables.boolean_meaning]
  simp [tableLocals, Locals.set]

theorem importedCalls_subtypes (imports : Imports) (text : Source) (names : IntegerSubtypes.Environment) :
    importedCalls imports _ .subtypes text names = subtypesValid text names := by
  change ValidityTables.subtypeBody.eval ValidityTables.modelCalls _ = _
  rw [ValidityTables.subtype_meaning]
  simp [tableLocals, Locals.set]

theorem importedCalls_mutable (imports : Imports) (names : ScalarExpression.Environment) :
    importedCalls imports _ .mutableBounds names = mutableBoundsValid names := by
  change ValidityTables.mutableBody.eval ValidityTables.modelCalls _ = _
  rw [ValidityTables.mutable_meaning]
  simp [tableLocals, Locals.set]

theorem importedCalls_values (imports : Imports) (names : ScalarExpression.Environment) (count : Nat) :
    importedCalls imports _ .declarationValues names count = declarationValuesValid names count := by
  change ValidityTables.valuesBody.eval ValidityTables.modelCalls _ = _
  rw [ValidityTables.values_meaning]
  simp [tableLocals, Locals.set]

/-- All metadata predicates are instantiated through their existing complete-domain
source interpretations. Their native subtype assumptions stay explicit. -/
theorem imported_validState (imports : Imports) (locals : Locals)
    (valid : Compose.Expressions.ValidText (locals .source "text"))
    (typed : ImportedTypes (locals .state "state")) :
    validStateBody.eval (importedCalls imports) locals =
      stateValid (locals .source "text") (locals .state "state") := by
  dsimp only [validStateBody, List.foldl, Expr.eval, app2, nameState,
    text, state, scalars, limit, Field.get]
  rw [importedCalls_names, importedCalls_scalars, importedCalls_subtypes,
    importedCalls_booleans, importedCalls_mutable, importedCalls_values]
  dsimp only [importedCalls]
  rw [(FunctionBindings.SourceBridge.interpreted_complete imports.functions imports.functionSource).validMetadata
      _ valid _ typed.functions,
    (ProcedureBindings.SourceBridge.interpreted_complete imports.procedures imports.procedureSource).validMetadata
      _ valid _ typed.procedures,
    (ArrayBindings.SourceBridge.interpreted_predicates imports.arrays imports.arraySource).validEnvironment
      _ valid _ typed.arrays]
  rfl

end Silver.ApplicationPackageFrames.ValidityNative
