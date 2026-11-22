module

public import Silver.ApplicationPackageCompletionEquations

@[expose] public section

/-! The initializer block's context is local to the block. Reading an output
initializer updates its cursor/effect locals and restores the complete hidden
context binding, without introducing that output formal into the frame. -/
namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def readContext (calls : CompletionCalls) (locals : Locals) : Predicate.ParseContext :=
  {calls.contextOf ⟨locals .state "frame", false, false⟩ with declarationCount := 0}

def readValueAfter (calls : CompletionCalls) (locals : Locals) : Nat :=
  let formal := locals .formal "formal"
  let context := readContext calls locals
  calls.actualAfter (locals .source "text") context (locals .number "value_first") (calls.initialFlow context)
    ⟨formal.bodyName.first, formal.bodyName.after, formal.kind, formal.bounds, 0⟩

def readContextStep (calls : CompletionCalls) (locals : Locals) : Locals :=
  let after := readValueAfter calls locals
  let reads := PackageBindings.stateUnion (locals .stateSet "reads")
    (calls.stateReads (locals .source "text") (readContext calls locals) (locals .metadata "info")
      (locals .number "value_first") after)
  (locals.set .number "value_after" after).set .stateSet "reads" reads

theorem outputReadBlock_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    outputReadBlock.eval (modelFunctions calls) (modelProcedures calls) fuel locals =
      some ⟨readContextStep calls locals, false⟩ := by
  dsimp only [outputReadBlock, outputReadBody, outputReadContext, readContextStep, readContext, readValueAfter,
    ApplicationPackageProcedure.Command.list, List.foldr, List.foldl,
    ApplicationPackageProcedure.Command.eval, Outcome.bind, Outcome.restore,
    Declaration.eval, Declaration.names, Declarations.restore,
    Place.set, Place.expression, Expr.eval, Updates.eval, Field.get, Field.set,
    modelFunctions, Locals.set, text, frame, info, formal, context, contextOf, union, reads]
  apply congrArg (fun store : Locals => some (Outcome.mk store false))
  funext ty key
  by_cases named : key = "context"
  · subst key
    simp [Declarations.restore, Declaration.names, Locals.set]
  · simp [Declarations.restore, Declaration.names, Locals.set, named]

theorem outputReadBlock_function (calls : CompletionCalls) (fuel : Nat) :
    outputReadBlock.eval (modelFunctions calls) (modelProcedures calls) fuel =
      (fun locals => some ⟨readContextStep calls locals, false⟩) :=
  funext (outputReadBlock_meaning calls fuel)

def readStep (calls : CompletionCalls) (locals : Locals) : Outcome :=
  let text := locals .source "text"
  let frame := locals .state "frame"
  let formal := (locals .metadata "info").parameterAt (locals .number "i")
  let updated := locals.set .formal "formal" formal
  if formal.mode = .output then
    if !calls.validName text formal.bodyName then failed updated
    else
      let first := calls.skipAt text frame.position
      let last := calls.nameAfter text first
      let updated := (updated.set .number "first" first).set .number "last" last
      if !calls.sameName text ⟨first, last⟩ formal.bodyName then failed updated
      else
        let updated := updated.set .number "value_first" (calls.takeToken text last (.symbol ":="))
        let updated := readContextStep calls updated
        let following := calls.takeToken text (updated .number "value_after") (.symbol ";")
        let updated := updated.set .number "following" following
        if following ≤ frame.position then failed updated
        else ⟨(updated.set .state "frame" {frame with position := following}).set .truth "initialized" true, false⟩
  else ⟨updated, false⟩

def initializerFirst (calls : CompletionCalls) (locals : Locals) : Nat :=
  calls.takeToken (locals .source "text")
    (calls.nameAfter (locals .source "text") (calls.skipAt (locals .source "text") (locals .state "frame").position))
    (.symbol ":=")

def initializerAfter (calls : CompletionCalls) (locals : Locals) : Nat :=
  let formal := (locals .metadata "info").parameterAt (locals .number "i")
  let context := readContext calls locals
  calls.actualAfter (locals .source "text") context (initializerFirst calls locals) (calls.initialFlow context)
    ⟨formal.bodyName.first, formal.bodyName.after, formal.kind, formal.bounds, 0⟩

def initializerFollowing (calls : CompletionCalls) (locals : Locals) : Nat :=
  calls.takeToken (locals .source "text") (initializerAfter calls locals) (.symbol ";")

local macro "reduce_completion_read" : tactic => `(tactic|
  (simp only [outputRead, fail, ApplicationPackageProcedure.Command.list, List.foldr,
     eval_sequence, eval_assign, eval_choose, eval_returned, eval_nothing, outputReadBlock_function]
   dsimp only [readStep, failed, readContextStep, readValueAfter, readContext,
     initializerFollowing, initializerAfter, initializerFirst,
     Outcome.bind, Place.set, Place.expression, Expr.eval, Field.get, Field.set, Index.get,
     modelFunctions, Locals.set, text, frame, info, formal, position, output, validFormal, skip, after, token, same]
   simp_all [initializerFollowing, initializerAfter, initializerFirst, readContext]))

theorem outputRead_meaning (calls : CompletionCalls) (fuel : Nat) (locals : Locals) :
    outputRead.eval (modelFunctions calls) (modelProcedures calls) fuel locals = some (readStep calls locals) := by
  by_cases outputMode : ((locals .metadata "info").parameterAt (locals .number "i")).mode = .output
  · cases valid : calls.validName (locals .source "text")
      ((locals .metadata "info").parameterAt (locals .number "i")).bodyName
    · reduce_completion_read
    · cases named : calls.sameName (locals .source "text")
        ⟨calls.skipAt (locals .source "text") (locals .state "frame").position,
          calls.nameAfter (locals .source "text")
            (calls.skipAt (locals .source "text") (locals .state "frame").position)⟩
        ((locals .metadata "info").parameterAt (locals .number "i")).bodyName
      · reduce_completion_read
      · by_cases stalled : initializerFollowing calls locals ≤ (locals .state "frame").position
        · reduce_completion_read
        · reduce_completion_read
          have advances : ¬ initializerFollowing calls locals ≤ (locals .state "frame").position := by
            simp only [initializerFollowing, initializerAfter, initializerFirst, readContext]
            omega
          simp only [initializerFollowing, initializerAfter, initializerFirst, readContext] at advances
          simp [advances]
  · reduce_completion_read

end Silver.ApplicationPackageCompletion.Native
