module

public import Silver.ApplicationPackageMainExpressions

@[expose] public section

namespace Silver.ApplicationPackageMain.Native
open ApplicationNative

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

private def booleanReader (calls : ApplicationPackageMain.Calls) (sources : ApplicationUnits.Bundle)
    (exports : Compose.ParserState) (info : PackageBindings.Metadata) : ApplicationAdmission.AnalysisResult :=
  if !calls.samePackageSpelling (textOf sources) info (calls.importedPackage (sources.unitSource .mainBody)) ||
      decide ((contextClauses calls sources info).after = 0) then ApplicationAdmission.invalidAnalysis
  else if decide (mainStart calls sources info = 0) then ApplicationAdmission.invalidAnalysis
  else if decide ((argumentFrame calls sources exports info).position = 0) then ApplicationAdmission.invalidAnalysis
  else if decide ((bodyFrame calls sources exports info).position = 0) then ApplicationAdmission.invalidAnalysis
  else if (decide (following calls sources exports info = 0) ||
      decide (calls.skipAt (textOf sources) (following calls sources exports info) ≠ (textOf sources).length + 1)) ||
      !calls.completed (bodyScan calls sources exports info).scan.facts.path then ApplicationAdmission.invalidAnalysis
  else acceptedResult calls sources exports info

private theorem booleanReader_eq (calls : ApplicationPackageMain.Calls) (sources : ApplicationUnits.Bundle)
    (exports : Compose.ParserState) (info : PackageBindings.Metadata) :
    booleanReader calls sources exports info = packageMainAt calls sources exports info := by
  simp only [booleanReader, packageMainAt, Bool.or_eq_true, Bool.not_eq_true',
    decide_eq_true_eq, Bool.eq_false_iff, or_assoc]

local macro "reduce_main" : tactic => `(tactic|
  simp_all (config := {maxSteps := 200000}) only [
    Body.eval, mainBody, mainDeclarations, bodyDeclarations, Command.list,
    List.foldr, List.foldl, Declaration.eval, LocalType.type, Command.eval, Location.set, Location.expression,
    importedRejected, footerRejected, Expr.eval, modelFunctions, Field.get, Field.set, Index.get,
    Locals.set, sourceBundle, sourceText, exports, info, frame, contextClausesValue,
    argumentsWith, result, mainScan, take, booleanReader, textOf, contextClauses, mainStart,
    argumentFrame, declarationsFrame, bodyFrame, bodyScan, following, acceptedResult,
    Bool.or_eq_true, Bool.not_eq_true', Bool.eq_false_iff, Bool.false_eq_true, Bool.not_false,
    Bool.not_true, Bool.true_or, Bool.false_or, Bool.or_true, Bool.or_false,
    decide_true, decide_false, decide_eq_true_eq, reduceCtorEq, ↓reduceIte, ↓reduceDIte])

set_option linter.unusedSimpArgs false in
/-- The original function's uninitialized Frame/Start/Following locals are
universally quantified. Source guards are eliminated in execution order, before
reducing their typed state substitutions and decision-procedure arguments. -/
theorem mainBody_meaning (calls : ApplicationPackageMain.Calls) (locals : Locals) :
    mainBody.eval (modelFunctions calls) locals =
      packageMainAt calls (locals .bundle "sources") (locals .state "exports") (locals .metadata "info") := by
  rw [← booleanReader_eq]
  have textImported : ("text" : String) ≠ "imported" := by decide
  let sources := locals .bundle "sources"
  let originalExports := locals .state "exports"
  let originalInfo := locals .metadata "info"
  by_cases imported : calls.samePackageSpelling (textOf sources) originalInfo
      (calls.importedPackage (sources.unitSource .mainBody)) = true
  · by_cases missingContext : (contextClauses calls sources originalInfo).after = 0
    · dsimp only [sources, originalExports, originalInfo] at *
      reduce_main
    · by_cases missingStart : mainStart calls sources originalInfo = 0
      · dsimp only [sources, originalExports, originalInfo] at *
        reduce_main
      · cases arguments : (contextClauses calls sources originalInfo).argumentsWith
        all_goals
          by_cases missingArgument : (argumentFrame calls sources originalExports originalInfo).position = 0
          · dsimp only [sources, originalExports, originalInfo] at *
            reduce_main
          · by_cases missingBody : (bodyFrame calls sources originalExports originalInfo).position = 0
            · dsimp only [sources, originalExports, originalInfo] at *
              reduce_main
            · by_cases missingFooter : following calls sources originalExports originalInfo = 0
              · dsimp only [sources, originalExports, originalInfo] at *
                reduce_main
              · by_cases unfinished : calls.skipAt (textOf sources)
                    (following calls sources originalExports originalInfo) ≠ (textOf sources).length + 1
                · dsimp only [sources, originalExports, originalInfo] at *
                  reduce_main
                · by_cases incomplete : calls.completed (bodyScan calls sources originalExports originalInfo).scan.facts.path ≠ true
                  · dsimp only [sources, originalExports, originalInfo] at *
                    reduce_main
                  · dsimp only [sources, originalExports, originalInfo] at *
                    reduce_main
  · dsimp only [sources, originalExports, originalInfo] at *
    reduce_main

end Silver.ApplicationPackageMain.Native
