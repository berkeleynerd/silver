module

public import Silver.ProcedureHeaderAdmission

@[expose] public section

/-! A procedure signature is appended only after locals, input bindings,
source-written output initialization, ordinary body and closing name succeed.
The body sees exactly the earlier function and procedure signature prefixes. -/
namespace Silver.Compose
open Named

def procedureBodyAt (text : Source) (outer frame : ParserState) (first after : Nat)
    (arguments : Bool) : ParserState :=
  let locals := functionLocals text frame arguments
  if locals.position = 0 then invalidState else
  let bound := procedureInputFrame text locals
  if bound.position = 0 then invalidState else
  let start := {bound with position := fixedAfter text bound.position "begin" true}
  let ready := procedurePrefix text start
  if ready.position = 0 then invalidState else
  let context := {Predicate.contextOf ⟨ready, false, false⟩ with declarationCount := locals.scalarNames.length}
  let initialized := decide (ready.position > start.position)
  let scan := Predicate.bodyOf ⟨ready, initialized, false⟩
  let bodyResult := if initialized then
      Predicate.bodyTail text context scan .endOnly frame.functions frame.procedures
    else Predicate.readBody text context scan .endOnly frame.functions frame.procedures
  let endFirst := skipAt text (fixedAfter text bodyResult.position "end" true)
  let endAfter := nameAfter text endFirst
  let following := fixedAfter text endAfter ";" false
  if bodyResult.position = 0 ∨ endFirst = 0 ∨ endAfter ≤ endFirst ∨
      !equalName text first after endFirst endAfter ∨ following ≤ outer.position then invalidState else
  {outer with
    position := following
    procedures := ProcedureBindings.append frame.procedures ⟨first, after, frame.firstProcedureParameter,
      frame.procedures.parameters.length - frame.firstProcedureParameter + 1⟩
    «hiding» := hideName text outer.hiding first after
    assignedInFunctions := outer.assignedInFunctions || bodyResult.assigned
    subtypeNames := {outer.subtypeNames with hiddenCalls := outer.subtypeNames.hiddenCalls.add text first after}}

def procedureDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let start := fixedAfter text state.position "procedure" true
  let first := skipAt text start
  let after := nameAfter text first
  let opening := fixedAfter text after "(" false
  if start = 0 ∨ opening = 0 ∨ state.pure ∨ !newNameAllowed text state first after arguments ∨
      state.procedures.items.length = ProcedureBindings.maxProcedures ∨
      state.procedures.parameters.length = ProcedureBindings.maxFormals then invalidState else
  let initial := {initialState with
    position := opening
    pure := true
    subtypeNames := state.subtypeNames
    functions := state.functions
    procedures := state.procedures
    «hiding» := hideName text (hiddenOuter text state) first after
    firstProcedureParameter := state.procedures.parameters.length + 1}
  let header := procedureParametersAt text initial arguments
  if header.position = 0 then invalidState else
  let bodyStart := fixedAfter text header.position "is" true
  let writable := (header.procedures.parameters.drop (header.firstProcedureParameter - 1)).any
    (fun parameter => parameter.mode != .input)
  if bodyStart = 0 ∨ !writable then invalidState else
  procedureBodyAt text state {header with position := bodyStart} first after arguments

end Silver.Compose
