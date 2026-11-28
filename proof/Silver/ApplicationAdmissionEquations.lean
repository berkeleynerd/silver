module

public import Silver.ApplicationAdmissionExpressions

@[expose] public section

namespace Silver.ApplicationAdmission.Native
open ApplicationNative

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

private theorem finalGuard (a b c d e : Bool) (yes no : AnalysisResult) :
    (if ((!a || !b || !c || !d || !e) = true) then no else yes) =
      (if ((a && b && c && d && e) = true) then yes else no) := by
  cases a <;> cases b <;> cases c <;> cases d <;> cases e <;> rfl

private theorem guardSwap (test : Bool) (yes no : AnalysisResult) :
    (if ((!test) = true) then no else yes) = (if test = true then yes else no) := by
  cases test <;> rfl

/-- The command evaluator quantifies over every initial local value, including
all three Ada locals declared without initializers. Every observable read is
therefore justified by the preceding native assignment/call order. -/
theorem analyzeBody_meaning (calls : ApplicationAdmission.Calls) (locals : Locals) :
    analyzeBody.eval (modelCallees calls) locals =
      analyzeApplication calls (locals .bundle "sources") := by
  dsimp only [Body.eval, analyzeBody, Command.list, List.foldr, List.foldl,
    Declaration.eval, Command.eval, forKinds, originalKinds, Location.set, Location.expression,
    sourceRejected, specificationRejected, bodyRejected, resultRejected,
    Expr.eval, modelCallees, modelFunctions, Field.get, Field.set, Locals.set,
    sourceBundle, sourceText, exports, info, result, unitPrefix,
    reduceCtorEq, ↓reduceIte, ↓reduceDIte]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte]
  simp only [analyzeApplication, chargeUnits, originalKinds, resultValid, finalGuard, guardSwap, id_eq]
  let sources := locals .bundle "sources"
  generalize chargedSpecification : calls.chargeUnit (sources.unitSource .packageSpecification)
    Compose.maxConcatenations = specificationCharge
  generalize chargedBody : calls.chargeUnit (sources.unitSource .packageBody)
    specificationCharge.remaining = bodyCharge
  generalize chargedMain : calls.chargeUnit (sources.unitSource .mainBody)
    bodyCharge.remaining = mainCharge
  cases first : specificationCharge.accepted <;>
    cases second : bodyCharge.accepted <;>
    cases third : mainCharge.accepted <;> simp_all


@[simp] theorem modelAlias_meaning (calls : ApplicationAdmission.Calls) (locals : Locals) :
    analyzeModelBody.eval (modelFunctions calls) locals =
      analyzeModel calls (locals .bundle "sources") := rfl

@[simp] theorem analyzeAlias_meaning (calls : ApplicationAdmission.Calls) (locals : Locals) :
    analyzeAliasBody.eval (modelFunctions calls) locals =
      analyze calls (locals .bundle "sources") := rfl

@[simp] theorem memberBody_meaning (calls : ApplicationAdmission.Calls) (locals : Locals) :
    memberBody.eval (modelFunctions calls) locals =
      isApplicationMember calls (locals .bundle "sources") := rfl

@[simp] theorem acceptsBody_meaning (calls : ApplicationAdmission.Calls) (locals : Locals) :
    acceptsBody.eval (modelFunctions calls) locals =
      acceptsApplication calls (locals .bundle "sources") := rfl

end Silver.ApplicationAdmission.Native
