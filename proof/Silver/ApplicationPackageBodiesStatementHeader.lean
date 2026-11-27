module

public import Silver.ApplicationPackageBodiesStatementCopy

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

abbrev HeaderContinuation := Input → Iteration → Option ApplicationScan

def afterHeader (current : Input) (header : Option Iteration) (next : HeaderContinuation) : Option ApplicationScan :=
  match header with
  | none => some (invalidApplication current.input)
  | some value => next current value

theorem binder_meaning (calls : Statement.Calls) (valid : ValidFlow) (locals : Locals) :
    binderRejected.eval (functions calls valid) locals =
      rejectedBinder calls (source locals) (locals .number "first") (locals .number "last") := by
  dsimp only [binderRejected, Expr.eval, zero, first, last, text, context, info, nameIs,
    Field.get, functions, rejectedBinder, source]

local macro "reduce_array_header" : tactic => `(tactic|
  (dsimp only [arrayCommands, Statements.Command.list, List.foldr, Statements.Command.eval,
     Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get, Property.get, enter, Declaration.eval,
     Declaration.names, List.foldl, Declarations.restore, arrayDeclarations, arrayRejected, row, arrayFirst, arrayLast,
     text, context, info, result, scan, position, input, invalid, nonzero, zero, keyword, token, skip, after,
     first, last, functions, Locals.set, atPosition, source, iteration, afterHeader, arrayHeader, afterReverse,
     rejectedArrayIterator, Predicate.ParseContext.arrayTable]
   simp_all [-Nat.not_le, -Nat.not_lt, -not_or, afterReverse, rejectedArrayIterator, Declaration.names, source, Predicate.ParseContext.arrayTable, or_assoc]))

theorem arrayCommands_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : HeaderContinuation) (leave : Continuation) :
    arrayCommands.eval (functions calls valid) (procedures calls) fuel locals
      (fun current => next (source current) (iteration current)) leave =
    afterHeader (source locals) (arrayHeader calls (source locals) (locals .appScan "result")
      (locals .number "first") (locals .number "last")) next := by
  let scope := source locals
  let afterOf := calls.takeToken scope.text (locals .number "last") (.word "of")
  let position := afterReverse calls scope.text afterOf
  by_cases pure : scope.context.pure = true
  · dsimp [scope, source] at pure
    reduce_array_header
  · by_cases reverse : calls.takeToken scope.text afterOf (.word "reverse") = 0
    all_goals by_cases bad : rejectedArrayIterator calls scope (locals .number "first") (locals .number "last") position = true
    all_goals dsimp only [position, afterOf, scope, source] at pure reverse bad
    all_goals reduce_array_header

local macro "reduce_counted_header" : tactic => `(tactic|
  (dsimp only [countedCommands, Statements.Command.list, List.foldr, Statements.Command.eval,
     Place.set, Place.expression, Expr.eval, Field.get, Field.set, Property.get, Updates.eval, enter, Declaration.eval,
     Declaration.names, List.foldl, Declarations.restore, shapeDeclaration, readBound, low, high, shape, lowBounds,
     highBounds, text, context, info, result, scan, position, input, inputScan, inputFacts, nonzero, keyword, token,
     first, last, start, reads, readEffects, addReads, isEmpty, functions, Locals.set, atPosition, source,
     iteration, countedHeader, afterReverse]
   simp_all [-Nat.not_le, -Nat.not_lt, afterReverse, Declaration.names, source]))

theorem countedCommands_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : HeaderContinuation) (leave : Continuation) :
    countedCommands.eval (functions calls valid) (procedures calls) fuel locals
      (fun current => next (source current) (iteration current)) leave =
    next (source locals) (countedHeader calls (source locals) (locals .appScan "result")
      (locals .number "first") (locals .number "last")) := by
  let s := source locals
  let afterIn := calls.takeToken s.text (locals .number "last") (.word "in")
  let start := afterReverse calls s.text afterIn
  let shapeResult := calls.readArrayAttribute s.text start s.context.scalarNames s.context.arrayTable
    (locals .number "first") (locals .number "last") true
  by_cases reverse : calls.takeToken s.text afterIn (.word "reverse") = 0
  all_goals by_cases counted : shapeResult.after = 0
  all_goals dsimp only [shapeResult, start, afterIn, s, source] at reverse counted
  all_goals reduce_counted_header

end Silver.ApplicationPackageBodies.Statement.Native
