module

public import Silver.ApplicationPackageBodiesModel

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

structure Calls where
  takeToken : Source → Nat → ShellToken → Nat
  skipAt : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  forbiddenName : Source → Nat → Nat → Bool
  nameIs : Source → Nat → Nat → String → Bool
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool
  readCondition : Source → ParseContext → Nat → ActiveFlow → ConditionResult
  stateReads : Source → ParseContext → PackageBindings.Metadata → Nat → Nat → PackageBindings.StateSet
  applicationTail : Source → ParseContext → ApplicationScan → PackageBindings.Metadata → BodyStop → Bool →
    FunctionBindings.Metadata → ProcedureBindings.Metadata → ApplicationScan
  joinInto : ActiveFlow → ActiveFlow → ActiveFlow
  arrayTarget : Source → ParseContext → Nat → Nat
  readArrayAttribute : Source → Nat → ScalarExpression.Environment → ArrayBindings.Table → Nat → Nat → Bool → ScalarExpression.Result
  readCountedBound : Source → ParseContext → Nat → ActiveFlow → Nat → Nat → ScalarExpression.Result
  widenInto : ParseContext → ActiveFlow → ActiveFlow
  pathJoin : PathFacts.Context → PathFacts.Context → PathFacts.Context
  bodyToken : Source → ParseContext → BodyScan → ShellToken → BodyScan
  validContext : Source → ParseContext → Bool
  validBody : Source → ParseContext → BodyScan → Bool
  applicationBasic : Source → ParseContext → ApplicationScan → PackageBindings.Metadata →
    FunctionBindings.Metadata → ProcedureBindings.Metadata → ApplicationScan

structure Input where
  text : Source
  context : ParseContext
  input : ApplicationScan
  info : PackageBindings.Metadata
  catalog : FunctionBindings.Metadata
  procedures : ProcedureBindings.Metadata

def atPosition (value : ApplicationScan) (position : Nat) : ApplicationScan :=
  {value with scan := {value.scan with position}}

def withFacts (value : ApplicationScan) (facts : ActiveFlow) : ApplicationScan :=
  {value with scan := {value.scan with facts}}

def tail (calls : Calls) (source : Input) (context : ParseContext) (value : ApplicationScan) (stop : BodyStop) : ApplicationScan :=
  calls.applicationTail source.text context value source.info stop true source.catalog source.procedures

def closeTokens (calls : Calls) (source : Input) (value : ApplicationScan) (middle : ShellToken) : ApplicationScan :=
  let ended := calls.bodyToken source.text source.context value.scan (.word "end")
  let closed := calls.bodyToken source.text source.context ended middle
  {value with scan := calls.bodyToken source.text source.context closed (.symbol ";")}

def validate (calls : Calls) (source : Input) (result : ApplicationScan) : ApplicationScan :=
  if result.scan.position ≤ source.input.scan.position ∨ !calls.validBody source.text source.context result.scan
  then invalidApplication source.input else result

structure Arms where
  value : ApplicationScan
  yes : ActiveFlow
  haveYes : Bool

inductive ArmStep
  | failed
  | finished (state : Arms)
  | continued (state : Arms)

structure ReadArm where
  branch : ApplicationScan
  yes : ActiveFlow
  haveYes : Bool
  whenFalse : ActiveFlow
  start : Nat

def conditionFor (calls : Calls) (source : Input) (state : Arms) : ConditionResult :=
  calls.readCondition source.text source.context state.value.scan.position state.value.scan.facts

def thenInput (calls : Calls) (source : Input) (state : Arms) (condition : ConditionResult) : ApplicationScan :=
  let position := calls.takeToken source.text condition.after (.word "then")
  let reads := PackageBindings.stateUnion state.value.reads
    (calls.stateReads source.text source.context source.info state.value.scan.position condition.after)
  withFacts (atPosition {state.value with reads} position) condition.whenTrue

def readArm (calls : Calls) (source : Input) (state : Arms) : Option ReadArm :=
  let condition := conditionFor calls source state
  if condition.after = 0 then none
  else
    let value := thenInput calls source state condition
    if value.scan.position ≤ state.value.scan.position then none
    else
      let branch := tail calls source source.context value .arm
      if branch.scan.position = 0 then none
      else some ⟨branch, state.yes, state.haveYes, condition.whenFalse, state.value.scan.position⟩

def finishArm (calls : Calls) (source : Input) (read : ReadArm) : ArmStep :=
  let yes := if read.haveYes then calls.joinInto read.yes read.branch.scan.facts else read.branch.scan.facts
  let value := withFacts read.branch read.whenFalse
  let following := calls.takeToken source.text value.scan.position (.word "elsif")
  if following = 0 then .finished ⟨value, yes, true⟩
  else if following ≤ read.start then .failed
  else .continued ⟨atPosition value following, yes, true⟩

def armStep (calls : Calls) (source : Input) (state : Arms) : ArmStep :=
  match readArm calls source state with
  | none => .failed
  | some read => finishArm calls source read

def armsFuel (step : Arms → ArmStep) : Nat → Arms → Option (Option Arms)
  | 0, _ => none
  | count + 1, state => match step state with
    | .failed => some none
    | .finished result => some (some result)
    | .continued next => armsFuel step count next

def closeIf (calls : Calls) (source : Input) (state : Arms) : ApplicationScan :=
  let afterElse := calls.takeToken source.text state.value.scan.position (.word "else")
  let branch := if afterElse ≠ 0 then tail calls source source.context (atPosition state.value afterElse) .endOnly else state.value
  if branch.scan.position = 0 then invalidApplication source.input
  else validate calls source (closeTokens calls source (withFacts branch (calls.joinInto branch.scan.facts state.yes)) (.word "if"))

structure Iteration where
  value : ApplicationScan
  first : Nat
  last : Nat
  bounds : Integer.Interval
  definite : Bool

def afterReverse (calls : Calls) (text : Source) (position : Nat) : Nat :=
  let following := calls.takeToken text position (.word "reverse")
  if following = 0 then position else following

def rejectedBinder (calls : Calls) (source : Input) (first last : Nat) : Bool :=
  decide (first = 0) || decide (last ≤ first) ||
    (calls.forbiddenName source.text first last && !calls.nameIs source.text first last "string") ||
    (source.context.hasArguments && calls.nameIs source.text first last "silver_arguments") ||
    calls.sameName source.text ⟨first, last⟩ ⟨source.info.nameFirst, source.info.nameAfter⟩ ||
    decide (source.context.scalarNames.length = ScalarExpression.maxBindings)

def rejectedArrayIterator (calls : Calls) (source : Input) (first last position : Nat) : Bool :=
  let arrayFirst := calls.skipAt source.text position
  let arrayLast := calls.nameAfter source.text arrayFirst
  let index := calls.arrayTarget source.text source.context position
  let row := ArrayBindings.binding source.context.arrayNames index
  decide (arrayFirst = 0) || decide (arrayLast ≤ arrayFirst) || calls.equalName source.text first last arrayFirst arrayLast ||
    decide (index = 0) || row.mutable || row.isBoolean

def arrayHeader (calls : Calls) (source : Input) (base : ApplicationScan) (first last : Nat) : Option Iteration :=
  let afterOf := calls.takeToken source.text last (.word "of")
  if source.context.pure then none
  else
    let position := afterReverse calls source.text afterOf
    let arrayFirst := calls.skipAt source.text position
    let arrayLast := calls.nameAfter source.text arrayFirst
    let index := calls.arrayTarget source.text source.context position
    let row := ArrayBindings.binding source.context.arrayNames index
    if rejectedArrayIterator calls source first last position then none
    else some ⟨atPosition base (calls.takeToken source.text arrayLast (.word "loop")), first, last, row.componentBounds, true⟩

def countedHeader (calls : Calls) (source : Input) (base : ApplicationScan) (first last : Nat) : Iteration :=
  let start := afterReverse calls source.text (calls.takeToken source.text last (.word "in"))
  let shape := calls.readArrayAttribute source.text start source.context.scalarNames source.context.arrayTable first last true
  let (position, bounds, definite) := if shape.after ≠ 0 then
      (calls.takeToken source.text shape.after (.word "loop"), shape.bounds, true)
    else
      let low := calls.readCountedBound source.text source.context start source.input.scan.facts first last
      let high := calls.readCountedBound source.text source.context (calls.takeToken source.text low.after (.symbol ".."))
        source.input.scan.facts first last
      let bounds := if low.bounds.isEmpty || high.bounds.isEmpty then Integer.Interval.empty
        else Integer.Interval.normalize ⟨low.bounds.lower, high.bounds.upper⟩
      (calls.takeToken source.text high.after (.word "loop"), bounds,
        !low.bounds.isEmpty && !high.bounds.isEmpty && decide (low.bounds.upper ≤ high.bounds.lower))
  let reads := calls.stateReads source.text {source.context with maskFirst := first, maskAfter := last} source.info start position
  let value := atPosition {base with reads := PackageBindings.stateUnion base.reads reads} position
  ⟨value, first, last, bounds, definite⟩

def forHeader (calls : Calls) (source : Input) (afterFor : Nat) : Option Iteration :=
  let first := calls.skipAt source.text afterFor
  let last := calls.nameAfter source.text first
  if rejectedBinder calls source first last then none
  else if calls.takeToken source.text last (.word "of") ≠ 0 then arrayHeader calls source source.input first last
  else some (countedHeader calls source source.input first last)

def innerContext (source : Input) (iteration : Iteration) : ParseContext :=
  {source.context with scalarNames := source.context.scalarNames ++
    [⟨iteration.first, iteration.last, iteration.bounds, false, iteration.bounds, false, 0, 0⟩]}

def innerInput (source : Input) (iteration : Iteration) (widened : ActiveFlow) : ApplicationScan :=
  let count := source.input.count
  let values := (List.range count).map (fun i => widened.values.getD i .empty) ++ [iteration.bounds]
  withFacts iteration.value ⟨if iteration.bounds.isEmpty then PathFacts.Context.empty else widened.path, values⟩

def afterIteration (calls : Calls) (source : Input) (iteration : Iteration) (widened : ActiveFlow)
    (inside : ApplicationScan) : ApplicationScan :=
  let facts := if iteration.bounds.isEmpty then source.input.scan.facts
    else {widened with path := if iteration.definite then inside.scan.facts.path
      else calls.pathJoin source.input.scan.facts.path inside.scan.facts.path}
  {iteration.value with scan := {inside.scan with facts}, reads := inside.reads, writes := inside.writes}

def forStatement (calls : Calls) (source : Input) (afterFor : Nat) : ApplicationScan :=
  match forHeader calls source afterFor with
  | none => invalidApplication source.input
  | some iteration =>
    if iteration.value.scan.position ≤ source.input.scan.position then invalidApplication source.input
    else
      let widened := calls.widenInto source.context iteration.value.scan.facts
      let inside := tail calls source (innerContext source iteration) (innerInput source iteration widened) .endOnly
      if inside.scan.position = 0 then invalidApplication source.input
      else validate calls source (closeTokens calls source (afterIteration calls source iteration widened inside) (.word "loop"))

def statementFuel (calls : Calls) (fuel : Nat) (source : Input) : Option ApplicationScan :=
  if source.input.scan.position = 0 then some (invalidApplication source.input)
  else
    let afterIf := calls.takeToken source.text source.input.scan.position (.word "if")
    if afterIf ≠ 0 then
      (armsFuel (armStep calls source) fuel ⟨atPosition source.input afterIf, source.input.scan.facts, false⟩).map
        (fun done => match done with | none => invalidApplication source.input | some state => closeIf calls source state)
    else
      let afterFor := calls.takeToken source.text source.input.scan.position (.word "for")
      if afterFor ≠ 0 then some (forStatement calls source afterFor)
      else some (calls.applicationBasic source.text source.context source.input source.info source.catalog source.procedures)

end Silver.ApplicationPackageBodies.Statement
