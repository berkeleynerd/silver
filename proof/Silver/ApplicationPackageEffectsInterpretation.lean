module

public import Silver.ApplicationPackageEffectsNative
public import Silver.ApplicationNativeLoopFacts

@[expose] public section

namespace Silver.ApplicationPackageEffects.Native
open Compose Predicate ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem visible_denotation (calls : ApplicationPackageEffects.Calls) (locals : Locals) :
    visibleBody.eval (callsOf calls) locals =
      visibleState calls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .number "index") := by
  dsimp only [visibleBody, Body.eval, Declaration.eval, Declaration.names, Command.list,
    Command.eval, Place.set, Place.expression, Expr.eval, callsOf,
    app2, app3, app4, text, context, info, indexValue, name, scalar, flag, scalarNames, booleanNames,
    Field.get, Index.get, visibleState, List.foldl, List.foldr]
  simp [Locals.set]

theorem target_denotation (calls : ApplicationPackageEffects.Calls) (locals : Locals) :
    targetBody.eval (callsOf calls) locals =
      stateTarget calls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .number "position") := by
  dsimp only [targetBody, Body.eval, Declaration.eval, Declaration.names,
    Command.eval, Expr.eval, callsOf, app2, app3, app4, text, context, info, first, found,
    Field.get, Index.get, stateTarget, List.foldl]
  simp [Locals.set]

theorem reads_body_denotation (calls : ApplicationPackageEffects.Calls) (locals : Locals)
    (next : Locals → PackageBindings.StateSet) :
    Command.eval (resultType := .stateSet) (callsOf calls) locals next readsLoopBody =
      next (locals.set .stateSet "result"
        (readStep calls (locals .source "text") (locals .parseContext "context")
          (locals .metadata "info") (locals .number "first") (locals .number "after")
          (locals .stateSet "result") (locals .number "i"))) := by
  dsimp only [readsLoopBody, Command.eval, Place.set, Place.expression, Expr.eval, callsOf,
    app2, app3, app4, app5, text, context, info, first, after, result, Field.get, Index.get, Index.set,
    readStep]
  split
  · rfl
  · rw [Locals.set_unchanged]

def readParameters (locals : Locals) :
    Source × ParseContext × PackageBindings.Metadata × Nat × Nat :=
  (locals .source "text", locals .parseContext "context", locals .metadata "info",
    locals .number "first", locals .number "after")

theorem reads_loop_denotation (calls : ApplicationPackageEffects.Calls) (locals : Locals)
    (next : Locals → PackageBindings.StateSet) :
    Command.eval (resultType := .stateSet) (callsOf calls) locals next
      (.forRange "i" (.number 1) (.field .stateCount info) readsLoopBody) =
      next (locals.set .stateSet "result"
        (((List.range (locals .metadata "info").states.length).map (· + 1)).foldl
          (readStep calls (locals .source "text") (locals .parseContext "context")
            (locals .metadata "info") (locals .number "first") (locals .number "after"))
          (locals .stateSet "result"))) := by
  change forValues
    (fun current continuation => Command.eval (callsOf calls) current continuation readsLoopBody)
    "i" ((List.range (locals .metadata "info").states.length).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  rw [show (fun i : Nat => 1 + i) = (fun i => i + 1) by funext i; omega]
  rw [forValues_accumulator (resultType := .stateSet) (accumulatorType := .stateSet)
    _ readParameters
    (fun params index state => readStep calls params.1 params.2.1 params.2.2.1
      params.2.2.2.1 params.2.2.2.2 state index) "i" "result" (Or.inl (by decide))
    (by intros; simp [readParameters, Locals.set])
    (by intros; simp [readParameters, Locals.set])
    (reads_body_denotation calls) _ locals _
    (by intros; simp only [Locals.set_shadow])]
  rw [Locals.set_commute_types _ .stateSet .number "result" "i" _ _ (by decide),
    Locals.set_unchanged]
  rfl

theorem reads_denotation (calls : ApplicationPackageEffects.Calls) (locals : Locals) :
    readsBody.eval (callsOf calls) locals =
      stateReads calls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .number "first") (locals .number "after") := by
  change (if decide (locals .number "first" = 0) ||
        decide (locals .number "after" ≤ locals .number "first") then
      PackageBindings.emptyStateSet
    else Command.eval (callsOf calls) (locals.set .stateSet "result" PackageBindings.emptyStateSet)
      (fun updated => updated .stateSet "result")
      (.forRange "i" (.number 1) (.field .stateCount info) readsLoopBody)) = _
  simp only [Bool.or_eq_true, decide_eq_true_eq]
  split
  · rename_i rejected
    simp only [stateReads, rejected, ↓reduceIte]
  · rename_i accepted
    rw [reads_loop_denotation]
    simp only [Locals.set_get_same,
      Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.stateSet ≠ Ty.source),
      Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.stateSet ≠ Ty.parseContext),
      Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.stateSet ≠ Ty.metadata),
      Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.stateSet ≠ Ty.number),
      stateReads, accepted, ↓reduceIte]

end Silver.ApplicationPackageEffects.Native
