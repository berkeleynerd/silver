module

public import Silver.ApplicationPackageRecursiveGuards
public import Silver.ApplicationPackageFunctionStatement
public import Silver.ApplicationPackageMainVisibleState
public import Silver.ApplicationPackageBodiesBasicSemantics

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate

/-- Callable identities are preserved in package bodies and translated into
Main's local/package tables only at the Main consumer. -/
structure CallNames where
  functions : Nat → Nat
  procedures : Nat → Nat

def packageNames : CallNames := ⟨id, id⟩

def mainNames (environment : Applications.Environment) : CallNames :=
  ⟨environment.packageFunctionId, environment.packageProcedureId⟩

/-- Concrete primitive readings used by all Basic source branches. The exact
native effect callbacks remain in the dictionary for the effect decoder. -/
def basicReaders (calls : BasicCalls) : BasicCalls :=
  Basic.withInheritedBody (Basic.functionReaders (Basic.procedureReaders calls))

theorem basicReaders_native (calls : BasicCalls) :
    Recursive.nativeBasicReaders (basicReaders calls) = basicReaders calls := rfl

theorem basicReaders_function (calls : BasicCalls) :
    Basic.functionReaders (basicReaders calls) = basicReaders calls := rfl

theorem basicReaders_procedure (calls : BasicCalls) :
    Basic.procedureReaders (basicReaders calls) = basicReaders calls := rfl

theorem basicReaders_inherited (calls : BasicCalls) :
    Basic.withInheritedBody (basicReaders calls) = basicReaders calls := rfl

/-- Original leaf syntax and dispatch only. There is no successful semantic
checker, valid-program, effect-coverage or obligation-discharge field. -/
inductive BasicCodeAt (calls : BasicCalls) (names : CallNames) (source : Statement.Input)
    (result : ApplicationScan) : Predicate.Statement → Prop
  | inherited {item : SourceStatement}
      (selected : Basic.origin calls source = .inherited)
      (returned : applicationBasic calls source.text source.context source.input source.info source.catalog source.procedures = result)
      (reading : BasicStepAt source.text source.context source.input.scan item result.scan source.catalog source.procedures) :
      BasicCodeAt calls names source result item.lower
  | functionCall {native : Predicate.Native.Context} {call : ScalarFunctions.Call}
      (context : native.model = source.context)
      (selected : Basic.origin calls source = .packageFunction)
      (returned : applicationBasic calls source.text source.context source.input source.info source.catalog source.procedures = result)
      (reading : Basic.FunctionCallAt source.text native source.input source.info
        (assignmentFirst calls source.text source.input) call) :
      BasicCodeAt calls names source result
        (.callAssign ⟨Predicate.functionAssignmentTarget source.text source.context source.input.scan,
          ⟨names.functions call.callee, call.actuals⟩⟩)
  | procedureCall {native : Predicate.Native.Context} {call : ScalarProcedures.Call}
      (context : native.model = source.context)
      (selected : Basic.origin calls source = .packageProcedure)
      (returned : applicationBasic calls source.text source.context source.input source.info source.catalog source.procedures = result)
      (reading : Basic.ProcedureCallAt source.text native source.input source.info source.input.scan.position call) :
      BasicCodeAt calls names source result (.procedureCall ⟨names.procedures call.callee, call.actuals⟩)

end Silver.ApplicationPackageBodies.SourceSyntax
