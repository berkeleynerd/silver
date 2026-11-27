module

public import Silver.ApplicationPackageCompletionProjection

@[expose] public section

namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies ApplicationPackages Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def atOriginal (scope : CompletionContext) : ParserState := {scope.globals with position := scope.original}

def observeThen (result : Outcome) (next : Locals → CompletionResult) : CompletionResult :=
  if result.returned then observed result.locals else next result.locals

def finishFooter (calls : CompletionCalls) (scope : CompletionContext) (result : ApplicationScan) : CompletionResult :=
  completionFooter calls scope.text (atOriginal scope) scope.info scope.index scope.item result

theorem footer_observed (calls : CompletionCalls) (locals : Locals) :
    observed (footerStep calls locals).locals =
      finishFooter calls (completionContext locals) (locals .appScan "result") := by
  dsimp only [footerStep, finishFooter, completionFooter, footerFirst, footerLast, footerFollowing,
    completionContext, atOriginal]
  split <;> simp_all [observed, failed, completionFailed, Locals.set]

def finishReturn (calls : CompletionCalls) (scope : CompletionContext) (context : Predicate.ParseContext)
    (result : ApplicationScan) : CompletionResult :=
  match completionReturn calls scope.text context scope.info scope.item result with
  | none => completionFailed scope.info
  | some returned => finishFooter calls scope returned

local macro "reduce_return" : tactic => `(tactic|
  (dsimp only [returnStep, finishReturn, completionReturn, returnedScan, returnedAfter, observeThen,
    failed, observed, completionFailed, completionContext, Locals.set]
   simp_all [-not_and, -not_or, returnedScan, returnedAfter]))

theorem return_observed (calls : CompletionCalls) (locals : Locals) :
    observeThen (returnStep calls locals)
      (fun returned => finishFooter calls (completionContext returned) (returned .appScan "result")) =
      finishReturn calls (completionContext locals) (locals .parseContext "context") (locals .appScan "result") := by
  by_cases function : (locals .routine "item").kind = .function
  · by_cases rejected : (returnedScan calls locals).scan.position = 0 ∨
        (returnedScan calls locals).writes ≠ PackageBindings.emptyStateSet
    · reduce_return
    · reduce_return
  · reduce_return

def finishDispatch (calls : CompletionCalls) (scope : CompletionContext) (context : Predicate.ParseContext)
    (result : ApplicationScan) : CompletionResult :=
  if result.scan.position = 0 then completionFailed scope.info else finishReturn calls scope context result

theorem dispatch_observed (calls : CompletionCalls) (locals : Locals) :
    observeThen (dispatchStep calls locals) (fun started =>
      finishReturn calls (completionContext started) (started .parseContext "context") (started .appScan "result")) =
        finishDispatch calls (completionContext locals) (locals .parseContext "context") (dispatched calls locals) := by
  simp only [dispatchStep, finishDispatch]
  split <;> simp_all [observeThen, failed, observed, completionFailed, completionContext, Locals.set]

theorem bodyStep_observed (calls : CompletionCalls) (locals : Locals) :
    (bodyStep calls locals).map (fun result => observed result.locals) =
      some (finishDispatch calls (completionContext locals) (locals .parseContext "context") (dispatched calls locals)) := by
  have equation : (bodyStep calls locals).map (fun result => observed result.locals) =
      some (observeThen (dispatchStep calls locals) (fun started => observeThen (returnStep calls started)
        (fun returned => observed (footerStep calls returned).locals))) := by
    by_cases stop : (dispatchStep calls locals).returned = true
    · simp [bodyStep, Outcome.bind, observeThen, stop]
    · by_cases rejected : (returnStep calls (dispatchStep calls locals).locals).returned = true <;>
        simp [bodyStep, Outcome.bind, observeThen, stop, rejected]
  rw [equation]
  simp only [footer_observed, return_observed, dispatch_observed]

def bodyLocals (calls : CompletionCalls) (locals : Locals) : Locals :=
  bodyDeclarations.foldl (Declaration.eval (modelFunctions calls)) locals

local macro "reduce_body_locals" : tactic => `(tactic|
  (dsimp only [bodyLocals, bodyDeclarations, List.foldl, Declaration.eval, Declaration.names,
    contextOf, frame, input, Expr.eval, Updates.eval, Field.get, Field.set, modelFunctions]
   simp [completionContext, initialization, Locals.set, applicationOf, completionInput, completionContextOf]))

theorem bodyLocals_scope (calls : CompletionCalls) (locals : Locals) :
    completionContext (bodyLocals calls locals) = completionContext locals := by reduce_body_locals

theorem bodyLocals_context (calls : CompletionCalls) (locals : Locals) :
    bodyLocals calls locals .parseContext "context" = completionContextOf calls (initialization locals) := by
  reduce_body_locals

theorem bodyLocals_input_count (calls : CompletionCalls) (locals : Locals) :
    bodyLocals calls locals .number "input_count" = (bodyLocals calls locals .appScan "input").count := by
  reduce_body_locals
  rfl

theorem bodyLocals_dispatched (calls : CompletionCalls) (locals : Locals) :
    dispatched calls (bodyLocals calls locals) =
      completionDispatch calls (locals .source "text") (locals .metadata "info") (locals .routine "item")
        (initialization locals) := by
  unfold dispatched dispatchInput completionDispatch
  reduce_body_locals

def finishBody (calls : CompletionCalls) (scope : CompletionContext) (state : InitializationFrame) : CompletionResult :=
  completionBody calls scope.text (atOriginal scope) scope.info scope.index scope.item state

theorem uncheckedBodyBlock_observed (calls : CompletionCalls) (locals : Locals) :
    (bodyBlockStep calls locals).map (fun result => observed result.locals) =
      some (uncheckedCompletionBody calls (locals .source "text") (atOriginal (completionContext locals))
        (locals .metadata "info") (locals .number "index") (locals .routine "item") (initialization locals)) := by
  have preserved (outcome : Outcome) : observed (outcome.restore (Declarations.restore bodyDeclarations locals)).locals =
      observed outcome.locals := by
    simp [observed, Outcome.restore, Declarations.restore, bodyDeclarations, Declaration.names]
  change ((bodyStep calls (bodyLocals calls locals)).map _).map _ = _
  simp only [Option.map_map, Function.comp_def, preserved, bodyStep_observed, bodyLocals_context, bodyLocals_scope,
    bodyLocals_dispatched]
  rfl

theorem bodyBlock_observed (calls : CompletionCalls) (locals : Locals) :
    (checkedBodyBlockStep calls locals).map (fun result => observed result.locals) =
      some (finishBody calls (completionContext locals) (initialization locals)) := by
  by_cases valid : calls.validState (locals .source "text") (locals .state "frame") = true
  · simp [checkedBodyBlockStep, finishBody, completionBody, completionContext, initialization,
      valid, uncheckedBodyBlock_observed]
  · simp [checkedBodyBlockStep, finishBody, completionBody, completionContext, initialization,
      valid, observed, failed, completionFailed, Locals.set]

end Silver.ApplicationPackageCompletion.Native
