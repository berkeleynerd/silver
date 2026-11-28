module

public import Silver.ApplicationPackageDeclarationsSpecificationSourceParts
import all Init.Data.Repr
import all Init.Data.Int.Repr

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ReaderSourceChecks
open Silver.SourceBridge ApplicationNative Control
open ApplicationPackageBodies.SourceChecks (ordinaryProcedure)

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

macro "specification_render" : tactic => `(tactic| (
  (try simp only [SpecificationNative.body, Control.Body.render, Statement.list, List.foldr, Statement.render,
      Statement.renderElse, Annotation.render, ApplicationPackageProcedure.Primitive.render, TableKind.count,
      SpecificationNative.entry, SpecificationNative.iteration, SpecificationNative.finish,
      SpecificationNative.signatureBranch, SpecificationNative.exportBranch, SpecificationNative.objectBranch,
      SpecificationNative.subtypeBranch, SpecificationNative.storeExport, SpecificationNative.progressCheck, SpecificationNative.rejected, SpecificationNative.rejectIf])
  (try dsimp only [Control.constant, Control.localDeclaration, Declaration.render, Declaration.names, Expr.render, Updates.render,
      Place.expression, Field.name, SpecificationNative.functionNames, SpecificationNative.text,
      SpecificationNative.info, SpecificationNative.exports, SpecificationNative.nextFrame,
      SpecificationNative.object, SpecificationNative.exportItem, SpecificationNative.first, SpecificationNative.last,
      SpecificationNative.name, SpecificationNative.position, SpecificationNative.nextPosition,
      SpecificationNative.exportCount, SpecificationNative.routineCount, SpecificationNative.lastRoutine,
      SpecificationNative.before, SpecificationNative.endFirst, SpecificationNative.endLast,
      SpecificationNative.following, SpecificationNative.take, SpecificationNative.item, SpecificationNative.itemName,
      SpecificationNative.mark, call2, call3, call4])
  decide +kernel))

private theorem declarations_render :
    SpecificationNative.body.declarations.flatMap (Declaration.render SpecificationNative.functionNames) =
      SpecificationTokens.declarations := by specification_render

private theorem entry_render :
    SpecificationNative.entry.render SpecificationNative.functionNames = SpecificationTokens.entry := by specification_render

private theorem signatureBranch_render :
    SpecificationNative.signatureBranch.render SpecificationNative.functionNames = SpecificationTokens.signatureBranch := by specification_render

private theorem subtypeBranch_render :
    SpecificationNative.subtypeBranch.render SpecificationNative.functionNames = SpecificationTokens.subtypeBranch := by specification_render

private theorem objectBranch_render :
    SpecificationNative.objectBranch.render SpecificationNative.functionNames = SpecificationTokens.objectBranch := by specification_render

private theorem objectBranch_renderElse :
    SpecificationNative.objectBranch.renderElse SpecificationNative.functionNames = ["else"] ++ SpecificationTokens.objectBranch := by
  rw [← objectBranch_render]
  simp only [SpecificationNative.objectBranch, Statement.list, List.foldr, Statement.renderElse]

private theorem storeExport_render :
    SpecificationNative.storeExport.render SpecificationNative.functionNames = SpecificationTokens.storeExport := by specification_render

private theorem progressCheck_render :
    SpecificationNative.progressCheck.render SpecificationNative.functionNames = SpecificationTokens.progressCheck := by specification_render

private theorem finish_render :
    SpecificationNative.finish.render SpecificationNative.functionNames = SpecificationTokens.finish := by specification_render

private theorem iteration_render :
    SpecificationNative.iteration.render SpecificationNative.functionNames = SpecificationTokens.iteration := by
  simp only [SpecificationNative.iteration, SpecificationNative.exportBranch, Statement.list, List.foldr,
    signatureBranch_render, subtypeBranch_render, objectBranch_renderElse, storeExport_render,
    progressCheck_render, Statement.render, Statement.renderElse]
  specification_render

private theorem body_render :
    SpecificationNative.body.render SpecificationNative.functionNames = SpecificationTokens.body := by
  change SpecificationNative.body.declarations.flatMap (Declaration.render SpecificationNative.functionNames) ++
    ["begin"] ++ SpecificationNative.entry.render SpecificationNative.functionNames ++
    (["loop"] ++ SpecificationNative.iteration.render SpecificationNative.functionNames ++ ["end","loop",";"]) ++
    SpecificationNative.finish.render SpecificationNative.functionNames ++ ["end","package_spec_at",";"] = _
  rw [declarations_render, entry_render, iteration_render, finish_render]
  simp [SpecificationTokens.body, SpecificationTokens.beginBody, SpecificationTokens.openLoop,
    SpecificationTokens.closeLoop, SpecificationTokens.endBody, List.append_assoc]

theorem specification_candidate_checked : SpecificationChecked specificationProfile specificationPackages where
  tree := SpecificationNative.checkedTree
  bodySource := specification_body_source.trans (congrArg some body_render.symm)
  headerSource := specification_header_source
  exportType := by decide +kernel
  objectDefault := specification_object_header_source

end Silver.ApplicationPackageDeclarations.ReaderSourceChecks
