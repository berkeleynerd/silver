module

public import Silver.ApplicationPackageDeclarationsSignatureSourceParts
import all Init.Data.Repr
import all Init.Data.Int.Repr

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ReaderSourceChecks
open Silver.SourceBridge ApplicationNative Control
open ApplicationPackageBodies.SourceChecks (ordinaryProcedure)

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/- Each lemma compares one portion of the typed tree with the literal tokens
of the corresponding native source range. The final equality reuses these
kernel-checked results at the procedure and loop boundaries. -/
macro "signature_render" : tactic => `(tactic| (
  (try simp only [SignatureNative.body, Control.Body.render, Statement.list, List.foldr, Statement.render, Statement.renderElse,
      Annotation.render, ApplicationPackageProcedure.Primitive.render, TableKind.count, SignatureNative.entry,
      SignatureNative.iteration, SignatureNative.finish, SignatureNative.invariants, SignatureNative.completeItem,
      SignatureNative.newItem, SignatureNative.selectSlot, SignatureNative.endParameter,
      SignatureNative.environmentAssertions, SignatureNative.storeParameter, SignatureNative.readMode,
      SignatureNative.completeParameter, SignatureNative.newParameter, SignatureNative.resultType,
      SignatureNative.rejected, SignatureNative.rejectIf, SignatureNative.returnIf])
  (try dsimp only [Control.constant, Control.localDeclaration, Declaration.render, Declaration.names, Expr.render, Updates.render,
      Place.expression, Field.name, SignatureNative.functionNames, SignatureNative.Calls, SignatureNative.text,
      SignatureNative.outer, SignatureNative.info, SignatureNative.header, SignatureNative.completing,
      SignatureNative.original, SignatureNative.functionEnd, SignatureNative.procedureEnd, SignatureNative.nameFirst,
      SignatureNative.nameAfter, SignatureNative.name, SignatureNative.item, SignatureNative.routineId,
      SignatureNative.formalCount, SignatureNative.formalStart, SignatureNative.opened, SignatureNative.first,
      SignatureNative.last, SignatureNative.nextPos, SignatureNative.modeEnd, SignatureNative.mode,
      SignatureNative.mark, SignatureNative.parameter, SignatureNative.slot, SignatureNative.before,
      SignatureNative.position, SignatureNative.outerPosition, SignatureNative.completed,
      SignatureNative.routineCount, SignatureNative.parameterCount, SignatureNative.itemCount,
      SignatureNative.itemStart, SignatureNative.itemFunction, SignatureNative.marked, SignatureNative.markedKind,
      SignatureNative.markedIdentity, SignatureNative.markedBounds, SignatureNative.markedName,
      SignatureNative.formalName, SignatureNative.take, SignatureNative.empty, SignatureNative.present,
      SignatureNative.inc, SignatureNative.validState, SignatureNative.duplicate, call2, call3, call4])
  decide +kernel))

private theorem render_list (names : FunctionNames Fn) (items : List (Statement Fn)) :
    (Statement.list items).render names = items.flatMap (Statement.render names) := by
  induction items with
  | nil => simp [Statement.list, Statement.render]
  | cons first rest ih =>
      change (Statement.sequence first (Statement.list rest)).render names = _
      rw [Statement.render]
      exact congrArg (fun tokens => first.render names ++ tokens) ih

private theorem declarations_render :
    SignatureNative.body.declarations.flatMap (Declaration.render SignatureNative.functionNames) =
      SignatureTokens.declarations := by signature_render

private theorem entry_render :
    SignatureNative.entry.render SignatureNative.functionNames = SignatureTokens.entry := by signature_render

private theorem invariants_render :
    SignatureNative.invariants.render SignatureNative.functionNames = SignatureTokens.invariants := by signature_render

private theorem selectSlot_render :
    SignatureNative.selectSlot.render SignatureNative.functionNames = SignatureTokens.selectSlot := by signature_render

private theorem readMode_render :
    SignatureNative.readMode.render SignatureNative.functionNames = SignatureTokens.readMode := by signature_render

private theorem storeParameter_render :
    SignatureNative.storeParameter.render SignatureNative.functionNames = SignatureTokens.storeParameter := by signature_render

private theorem endParameter_render :
    SignatureNative.endParameter.render SignatureNative.functionNames = SignatureTokens.endParameter := by signature_render

private theorem finish_render :
    SignatureNative.finish.render SignatureNative.functionNames = SignatureTokens.finish := by signature_render

private theorem iteration_render :
    SignatureNative.iteration.render SignatureNative.functionNames = SignatureTokens.iteration := by
  rw [SignatureNative.iteration, render_list]
  simp only [List.flatMap_cons, List.flatMap_nil, invariants_render, selectSlot_render, readMode_render,
    storeParameter_render, endParameter_render]
  signature_render

private theorem body_render :
    SignatureNative.body.render SignatureNative.functionNames = SignatureTokens.body := by
  change SignatureNative.body.declarations.flatMap (Declaration.render SignatureNative.functionNames) ++
    ["begin"] ++ SignatureNative.entry.render SignatureNative.functionNames ++
    (["if"] ++ (SignatureNative.present SignatureNative.opened.expression).render SignatureNative.functionNames ++
      ["then"] ++ (Statement.assign SignatureNative.position SignatureNative.opened.expression).render
        SignatureNative.functionNames ++
      (["loop"] ++ SignatureNative.iteration.render SignatureNative.functionNames ++ ["end","loop",";"]) ++
      ["end","if",";"]) ++ SignatureNative.finish.render SignatureNative.functionNames ++
    ["end","package_signature_at",";"] = _
  have guardTokens : (SignatureNative.present SignatureNative.opened.expression).render
      SignatureNative.functionNames = ["open", "/=", "0"] := by signature_render
  have startTokens : (Statement.assign SignatureNative.position SignatureNative.opened.expression).render
      SignatureNative.functionNames = ["header", ".", "position", ":=", "open", ";"] := by signature_render
  rw [declarations_render, entry_render, iteration_render, finish_render, guardTokens, startTokens]
  simp [SignatureTokens.body, SignatureTokens.beginBody, SignatureTokens.openLoop,
    SignatureTokens.closeLoop, SignatureTokens.endBody, List.append_assoc]

theorem signature_candidate_checked : SignatureChecked signatureProfile signaturePackages where
  tree := SignatureNative.checkedTree
  bodySource := signature_body_source.trans (congrArg some body_render.symm)
  headerSource := signature_header_source
  routineType := by decide +kernel
  formalType := by decide +kernel
  appendSource := signature_append_header_source

theorem append_candidate_checked : AppendChecked signatureProfile scalarAppendCandidate where
  headerSource := signature_candidate_checked.appendSource
  scalarHeader := by decide +kernel
  scalarBody := by decide +kernel

end Silver.ApplicationPackageDeclarations.ReaderSourceChecks
