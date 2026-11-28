module

public import Silver.ApplicationCallTranslation

@[expose] public section

/-! Application execution retains the entire existing Predicate statement
language and observable effects. Only procedure invocation can change package
globals; every statement sees the current shared state through fresh callable
environments. Main's strings, arrays, input and local callables retain their
ordinary semantics and checked operations. -/
namespace Silver.Applications
open Bindings Compose Predicate
open ScalarFunctions (Frame)

structure Execution where
  values : Values
  effects : List Sequence.Effect
  integers : Integer.Store
  booleans : Boolean.Store
  globals : Frame

def Execution.ordinary (result : Execution) : Predicate.Execution :=
  ⟨result.values, result.effects, result.integers, result.booleans⟩

def Execution.lift (globals : Frame) (result : Predicate.Execution) : Execution :=
  ⟨result.values, result.effects, result.integers, result.booleans, globals⟩

def Execution.restoreIndex (result : Execution) (index : Nat) (before : Integer.Store) : Execution :=
  {result with integers := Integer.restore before result.integers index}

def procedureGlobals (environment : Environment) (globals : Frame) (state : ScalarFunctions.State)
    (call : ScalarProcedures.Call) : Frame :=
  match call.resolve environment.procedureSignatures with
  | none => globals
  | some resolved => (environment.invokeProcedure globals call.callee
      (ScalarFunctions.evaluateActuals state resolved.actuals.inputs)).1

def atomGlobals (environment : Environment) (globals : Frame) (state : ScalarFunctions.State)
    (item : Predicate.Statement) : Frame :=
  match item with
  | .procedureCall call => procedureGlobals environment globals state call
  | _ => globals

def executeAtom (environment : Environment) (globals : Frame) (input : Source) (valid : Bool)
    (values : Values) (integers : Integer.Store) (booleans : Boolean.Store) (item : Predicate.Statement) : Execution :=
  Execution.lift (atomGlobals environment globals ⟨values, input, valid, integers, booleans⟩ item)
    (item.execute (functions := environment.functionsAt globals) (procedures := environment.proceduresAt globals)
      input valid values integers booleans)

def checkedAtom (environment : Environment) (globals : Frame) (input : Source) (valid : Bool)
    (values : Values) (integers : Integer.Store) (booleans : Boolean.Store)
    (item : Predicate.Statement) : Option Execution :=
  (item.checkedExecute (functions := environment.functionsAt globals) (procedures := environment.proceduresAt globals)
    input valid values integers booleans).map
      (Execution.lift (atomGlobals environment globals ⟨values, input, valid, integers, booleans⟩ item))

def executeIterations (step : Frame → Values → Integer.Store → Boolean.Store → Int → Execution) :
    Frame → Values → Integer.Store → Boolean.Store → List Int → Execution
  | globals, values, integers, booleans, [] => ⟨values, [], integers, booleans, globals⟩
  | globals, values, integers, booleans, index :: rest =>
      let first := step globals values integers booleans index
      let following := executeIterations step first.globals first.values first.integers first.booleans rest
      ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans, following.globals⟩

def checkedIterations (step : Frame → Values → Integer.Store → Boolean.Store → Int → Option Execution) :
    Frame → Values → Integer.Store → Boolean.Store → List Int → Option Execution
  | globals, values, integers, booleans, [] => some ⟨values, [], integers, booleans, globals⟩
  | globals, values, integers, booleans, index :: rest => (step globals values integers booleans index).bind fun first =>
      (checkedIterations step first.globals first.values first.integers first.booleans rest).map fun following =>
        ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans, following.globals⟩

mutual
  def executeStatement (environment : Environment) (globals : Frame) (input : Source) (valid : Bool)
      (values : Values) (item : Predicate.Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Execution :=
    match item with
    | .choice condition yes no =>
        if condition.evaluate values input valid integers booleans
        then executeStatements environment globals input valid values yes integers booleans
        else executeStatements environment globals input valid values no integers booleans
    | .forLoop index reverse lower upper body =>
        executeIterations (fun shared current scalars flags value =>
          (executeStatements environment shared input valid current body (Integer.put scalars index value) flags).restoreIndex index scalars)
          globals values integers booleans (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
    | .arrayLoop index reverse array body =>
        executeIterations (fun shared current scalars flags component =>
          (executeStatements environment shared input valid current body
            (Integer.put scalars index (array.project scalars component)) flags).restoreIndex index scalars)
          globals values integers booleans (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
    | item => executeAtom environment globals input valid values integers booleans item
  termination_by sizeOf item
  def executeStatements (environment : Environment) (globals : Frame) (input : Source) (valid : Bool)
      (values : Values) (items : List Predicate.Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Execution :=
    match items with
    | [] => ⟨values, [], integers, booleans, globals⟩
    | item :: rest =>
        let first := executeStatement environment globals input valid values item integers booleans
        let following := executeStatements environment first.globals input valid first.values rest first.integers first.booleans
        ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans, following.globals⟩
  termination_by sizeOf items
end

mutual
  def checkedStatement (environment : Environment) (globals : Frame) (input : Source) (valid : Bool)
      (values : Values) (item : Predicate.Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Option Execution :=
    match item with
    | .choice condition yes no =>
        (condition.checkedEvaluate values input valid integers booleans).bind fun outcome =>
          if outcome then checkedStatements environment globals input valid values yes integers booleans
          else checkedStatements environment globals input valid values no integers booleans
    | .forLoop index reverse lower upper body =>
        (lower.checkedEvaluate integers).bind fun a => (upper.checkedEvaluate integers).bind fun b =>
          checkedIterations (fun shared current scalars flags value =>
            (checkedStatements environment shared input valid current body (Integer.put scalars index value) flags).map
              fun result => result.restoreIndex index scalars)
            globals values integers booleans (Integer.iterationValues reverse a b)
    | .arrayLoop index reverse array body =>
        checkedIterations (fun shared current scalars flags component =>
          if array.bounds.Contains component then
            (Integer.checkedValue (array.project scalars component)).bind fun value =>
              (checkedStatements environment shared input valid current body (Integer.put scalars index value) flags).map
                fun result => result.restoreIndex index scalars
          else none) globals values integers booleans (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
    | item => checkedAtom environment globals input valid values integers booleans item
  termination_by sizeOf item
  def checkedStatements (environment : Environment) (globals : Frame) (input : Source) (valid : Bool)
      (values : Values) (items : List Predicate.Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Option Execution :=
    match items with
    | [] => some ⟨values, [], integers, booleans, globals⟩
    | item :: rest =>
        (checkedStatement environment globals input valid values item integers booleans).bind fun first =>
          (checkedStatements environment first.globals input valid first.values rest first.integers first.booleans).map fun following =>
            ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans, following.globals⟩
  termination_by sizeOf items
end

end Silver.Applications
