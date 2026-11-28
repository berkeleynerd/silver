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


def initialLocals (calls : ApplicationPackageMain.Calls) (locals : Locals) : Locals :=
  ((locals.set .source "text" (textOf (locals .bundle "sources"))).set .source "imported"
    (calls.importedPackage ((locals .bundle "sources").unitSource .mainBody))).set
      .contextClauses "context_clauses" (contextClauses calls (locals .bundle "sources") (locals .metadata "info"))

theorem mainDeclarations_eval (calls : ApplicationPackageMain.Calls) (locals : Locals) :
    mainDeclarations.foldl (Declaration.eval (modelFunctions calls)) locals = initialLocals calls locals := by
  rfl

def bodyLocals (calls : ApplicationPackageMain.Calls) (locals : Locals) : Locals :=
  let frame := locals .state "frame"
  let scan : Predicate.ScanResult := ⟨frame, frame.assignedInFunctions, false⟩
  let context := calls.contextOf scan
  let input := ApplicationPackages.applicationOf (calls.bodyOf scan)
  let result := calls.applicationTail (locals .source "text") context input
    (locals .metadata "info") .endOnly true frame.functions frame.procedures
  ((locals.set .parseContext "context" context).set .appScan "input" input).set .appScan "result" result

theorem bodyDeclarations_eval (calls : ApplicationPackageMain.Calls) (locals : Locals) :
    bodyDeclarations.foldl (Declaration.eval (modelFunctions calls)) locals = bodyLocals calls locals := by
  rfl

/-- Completion after the declaration reader, with every source observation
explicit and no assumptions about the supplied frame or call dictionary. -/
def finishResult (calls : ApplicationPackageMain.Calls) (text : Source)
    (info : PackageBindings.Metadata) (frame : Compose.ParserState) (arguments : Bool) :
    ApplicationAdmission.AnalysisResult :=
  let scan : Predicate.ScanResult := ⟨frame, frame.assignedInFunctions, false⟩
  let result := calls.applicationTail text (calls.contextOf scan)
    (ApplicationPackages.applicationOf (calls.bodyOf scan)) info .endOnly true frame.functions frame.procedures
  let following := calls.takeToken text (calls.takeToken text
    (calls.takeToken text result.scan.position (.word "end")) (.word "main")) (.symbol ";")
  if (decide (following = 0) || decide (calls.skipAt text following ≠ text.length + 1)) ||
      !calls.completed result.scan.facts.path then ApplicationAdmission.invalidAnalysis
  else
    { accepted := true
      packageInfo := info
      mainFunctions := frame.functions
      mainProcedures := frame.procedures
      usesArguments := arguments
      usesAssignment := result.scan.assigned
      usesOutput := result.scan.output }

theorem bodyCommands_eval (calls : ApplicationPackageMain.Calls) (locals : Locals)
    (next : Locals → ApplicationAdmission.AnalysisResult) :
    bodyCommands.eval (modelFunctions calls) locals next =
      finishResult calls (locals .source "text") (locals .metadata "info")
        (locals .state "frame") (locals .contextClauses "context_clauses").argumentsWith := by
  simp only [bodyCommands, Command.eval, bodyDeclarations_eval]
  rfl

def declarationResult (calls : ApplicationPackageMain.Calls) (text : Source)
    (info : PackageBindings.Metadata) (frame : Compose.ParserState) (arguments : Bool) :
    ApplicationAdmission.AnalysisResult :=
  let read := calls.readDeclarations text frame arguments
  let frame := {read with position := calls.takeToken text read.position (.word "begin")}
  if decide (frame.position = 0) then ApplicationAdmission.invalidAnalysis
  else finishResult calls text info frame arguments

theorem declarationCommands_eval (calls : ApplicationPackageMain.Calls) (locals : Locals)
    (next : Locals → ApplicationAdmission.AnalysisResult) :
    declarationCommands.eval (modelFunctions calls) locals next =
      declarationResult calls (locals .source "text") (locals .metadata "info")
        (locals .state "frame") (locals .contextClauses "context_clauses").argumentsWith := by
  simp only [declarationCommands, Command.list, List.foldr, Command.eval, bodyCommands_eval]
  rfl

def argumentResult (calls : ApplicationPackageMain.Calls) (text : Source)
    (info : PackageBindings.Metadata) (frame : Compose.ParserState) (arguments : Bool) :
    ApplicationAdmission.AnalysisResult :=
  let frame := if arguments then calls.argumentAt text frame else frame
  if decide (frame.position = 0) then ApplicationAdmission.invalidAnalysis
  else declarationResult calls text info frame arguments

theorem argumentCommands_eval (calls : ApplicationPackageMain.Calls) (locals : Locals)
    (next : Locals → ApplicationAdmission.AnalysisResult) :
    argumentCommands.eval (modelFunctions calls) locals next =
      argumentResult calls (locals .source "text") (locals .metadata "info")
        (locals .state "frame") (locals .contextClauses "context_clauses").argumentsWith := by
  simp only [argumentCommands, Command.list, List.foldr, Command.eval, declarationCommands_eval]
  dsimp only [Location.set, Location.expression, Expr.eval, modelFunctions, Field.get,
    Locals.set, sourceText, info, frame, contextClausesValue, argumentsWith, argumentResult]
  cases arguments : (locals .contextClauses "context_clauses").argumentsWith <;>
    simp_all only [Bool.false_eq_true, reduceCtorEq, ↓reduceIte, ↓reduceDIte]

/-- The original function's uninitialized locals and every callee interpretation
remain arbitrary. Each command phase is composed through its universal
continuation equation; no annotation is assumed true during execution. -/
theorem mainBody_meaning (calls : ApplicationPackageMain.Calls) (locals : Locals) :
    mainBody.eval (modelFunctions calls) locals =
      packageMainAt calls (locals .bundle "sources") (locals .state "exports") (locals .metadata "info") := by
  simp only [Body.eval, mainBody, Command.list, List.foldr, Command.eval,
    mainDeclarations_eval, argumentCommands_eval]
  rw [← booleanReader_eq]
  rfl

end Silver.ApplicationPackageMain.Native
