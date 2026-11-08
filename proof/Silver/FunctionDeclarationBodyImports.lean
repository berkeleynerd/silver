module

public import Silver.FunctionDeclarationBodyModel
public import Silver.FunctionDeclarationHeaderEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true

attribute [local irreducible] Predicate.bodyOf functionReturnAfter
  functionLocals parameterFrame fixedAfter skipAt Compose.nameAfter

structure BodyPartsImports (calls : Calls) (text : Source) (frame locals bound : ParserState)
    (resultType : FunctionTypeResult) : Prop where
  beginToken : calls .take text bound.position (.fixed "begin" true) = fixedAfter text bound.position "begin" true
  context : let p := bodyParts modelCalls text frame locals bound resultType
    calls .contextOf ⟨p.start, false, false⟩ = nativeContextOf ⟨p.start, false, false⟩
  initialScan : let p := bodyParts modelCalls text frame locals bound resultType
    calls .bodyOf ⟨p.start, false, false⟩ = Predicate.bodyOf ⟨p.start, false, false⟩
  bodyTail : let p := bodyParts modelCalls text frame locals bound resultType
    calls .bodyTail text p.context (Predicate.bodyOf ⟨p.start, false, false⟩) .returnOnly frame.functions = p.scan
  returnAfter : let p := bodyParts modelCalls text frame locals bound resultType
    calls .returnAfter text p.context p.scan resultType = p.returnEnd
  semicolon : let p := bodyParts modelCalls text frame locals bound resultType
    calls .take text p.returnEnd (.fixed ";" false) = fixedAfter text p.returnEnd ";" false
  endToken : let p := bodyParts modelCalls text frame locals bound resultType
    calls .take text (fixedAfter text p.returnEnd ";" false) (.fixed "end" true) =
      fixedAfter text (fixedAfter text p.returnEnd ";" false) "end" true
  skip : let p := bodyParts modelCalls text frame locals bound resultType
    calls .skip text (fixedAfter text (fixedAfter text p.returnEnd ";" false) "end" true) = p.endFirst
  nameAfter : let p := bodyParts modelCalls text frame locals bound resultType
    calls .nameAfter text p.endFirst = p.endAfter
  following : let p := bodyParts modelCalls text frame locals bound resultType
    calls .take text p.endAfter (.fixed ";" false) = p.following

theorem body_parts_imports (calls : Calls) (text : Source) (frame locals bound : ParserState)
    (resultType : FunctionTypeResult) (imports : BodyPartsImports calls text frame locals bound resultType) :
    bodyParts calls text frame locals bound resultType = bodyParts modelCalls text frame locals bound resultType := by
  conv => lhs; unfold bodyParts
  rw [imports.beginToken]
  dsimp +instances only
  rw (transparency := .default) [imports.context, imports.initialScan, imports.bodyTail,
    imports.returnAfter, imports.semicolon, imports.endToken, imports.skip, imports.nameAfter, imports.following]
  rfl

structure BodyFinishImports (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (parts : BodyParts) : Prop where
  equal : bodyPrefix parts = false →
    calls .equal text first after parts.endFirst parts.endAfter = Named.equalName text first after parts.endFirst parts.endAfter
  append : bodyRejected modelCalls text outer first after parts = false →
    calls .append frame.functions ⟨first, after, frame.firstParameter,
      frame.functions.parameters.length - frame.firstParameter + 1, resultType.kind, resultType.bounds⟩ =
      FunctionBindings.append frame.functions ⟨first, after, frame.firstParameter,
        frame.functions.parameters.length - frame.firstParameter + 1, resultType.kind, resultType.bounds⟩
  hide : bodyRejected modelCalls text outer first after parts = false →
    calls .hideName text outer.hiding first after = hideName text outer.hiding first after
  nameIs : bodyRejected modelCalls text outer first after parts = false → ∀ operation : Names.Operation,
    calls .nameIs text first after operation.name = Named.nameIs text first after (operation.name.toList.map Char.toNat)

theorem body_finish_imports (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (parts : BodyParts)
    (imports : BodyFinishImports calls text outer frame first after resultType parts) :
    bodyFinish calls text outer frame first after resultType parts = bodyFinish modelCalls text outer frame first after resultType parts := by
  have rejectedSame : bodyRejected calls text outer first after parts = bodyRejected modelCalls text outer first after parts := by
    unfold bodyRejected
    cases prefixEq : bodyPrefix parts with
    | true => simp only [Bool.true_or]
    | false => rw [imports.equal prefixEq]; rfl
  unfold bodyFinish
  rw [rejectedSame]
  cases rejected : bodyRejected modelCalls text outer first after parts with
  | true => simp only [↓reduceIte]
  | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      have output := imports.nameIs rejected .output
      have partialOutput := imports.nameIs rejected .partialOutput
      have argument := imports.nameIs rejected .argument
      have validity := imports.nameIs rejected .validity
      have reject := imports.nameIs rejected .reject
      simp only [Names.Operation.name] at output partialOutput argument validity reject
      rw [imports.append rejected, imports.hide rejected, output, partialOutput, argument, validity, reject]
      rfl

structure BodyImports (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) : Prop where
  locals : calls .functionLocals text frame arguments = functionLocals text frame arguments
  parameterFrame : let locals := functionLocals text frame arguments
    locals.position ≠ 0 → calls .parameterFrame text locals = Compose.parameterFrame text locals
  parts : let locals := functionLocals text frame arguments; let bound := Compose.parameterFrame text locals
    locals.position ≠ 0 → bound.position ≠ 0 → BodyPartsImports calls text frame locals bound resultType
  finish : let locals := functionLocals text frame arguments; let bound := Compose.parameterFrame text locals
    locals.position ≠ 0 → bound.position ≠ 0 →
    BodyFinishImports calls text outer frame first after resultType (bodyParts modelCalls text frame locals bound resultType)

theorem functionBody_imports (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool)
    (imports : BodyImports calls text outer frame first after resultType arguments) :
    functionBodyBody.eval calls ({text, outer, frame, first, after, resultType, arguments} : Frame).locals =
      functionBodyAt text outer frame first after resultType arguments := by
  rw [body_denotation, body_model_equation]
  dsimp only [bodyEquation]
  have modelLocals : modelCalls .functionLocals = functionLocals := rfl
  have modelFrame : modelCalls .parameterFrame = parameterFrame := rfl
  simp only [modelLocals, modelFrame]
  simp only [decide_eq_true_eq]
  rw [imports.locals]
  by_cases localsZero : (functionLocals text frame arguments).position = 0
  · simp only [localsZero, ↓reduceIte]
  · simp only [localsZero, ↓reduceIte]
    rw [imports.parameterFrame localsZero]
    by_cases boundZero : (parameterFrame text (functionLocals text frame arguments)).position = 0
    · simp only [boundZero, ↓reduceIte]
    · simp only [boundZero, ↓reduceIte]
      rw [body_parts_imports calls text frame _ _ resultType (imports.parts localsZero boundZero)]
      exact body_finish_imports calls text outer frame first after resultType _ (imports.finish localsZero boundZero)

end Silver.Compose.FunctionDeclarationNative
