module

public import Silver.ProcedureDeclarationBodyNative

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true

attribute [local irreducible] Predicate.bodyOf functionLocals procedureInputFrame
  procedurePrefix fixedAfter skipAt Compose.nameAfter

/-- Individual calls made after the source-written output prefix succeeds.
The selected body reader is required only on its actual branch. -/
structure BodyPartsImports (calls : Calls) (text : Source) (frame locals start ready : ParserState) : Prop where
  context : calls .contextOf ⟨ready, false, false⟩ = nativeContextOf ⟨ready, false, false⟩
  initialScan : let p := bodyParts modelCalls text frame locals start ready
    calls .bodyOf ⟨ready, p.initialized, false⟩ = Predicate.bodyOf ⟨ready, p.initialized, false⟩
  bodyTail : let p := bodyParts modelCalls text frame locals start ready
    p.initialized = true →
    calls .bodyTail text p.context p.scan .endOnly frame.functions frame.procedures = p.result
  readBody : let p := bodyParts modelCalls text frame locals start ready
    p.initialized = false →
    calls .readBody text p.context p.scan .endOnly frame.functions frame.procedures = p.result
  endToken : let p := bodyParts modelCalls text frame locals start ready
    calls .take text p.result.position (.fixed "end" true) = fixedAfter text p.result.position "end" true
  skip : let p := bodyParts modelCalls text frame locals start ready
    calls .skip text (fixedAfter text p.result.position "end" true) = p.endFirst
  nameAfter : let p := bodyParts modelCalls text frame locals start ready
    calls .nameAfter text p.endFirst = p.endAfter
  following : let p := bodyParts modelCalls text frame locals start ready
    calls .take text p.endAfter (.fixed ";" false) = p.following

theorem body_parts_imports (calls : Calls) (text : Source) (frame locals start ready : ParserState)
    (imports : BodyPartsImports calls text frame locals start ready) :
    bodyParts calls text frame locals start ready = bodyParts modelCalls text frame locals start ready := by
  have initialScan : calls .bodyOf ⟨ready, decide (ready.position > start.position), false⟩ =
      Predicate.bodyOf ⟨ready, decide (ready.position > start.position), false⟩ := imports.initialScan
  conv => lhs; unfold bodyParts
  dsimp +instances only
  rw (transparency := .default) [imports.context, initialScan]
  have selected :
      (if (bodyParts modelCalls text frame locals start ready).initialized then
        calls .bodyTail text (bodyParts modelCalls text frame locals start ready).context
          (bodyParts modelCalls text frame locals start ready).scan .endOnly frame.functions frame.procedures
      else calls .readBody text (bodyParts modelCalls text frame locals start ready).context
          (bodyParts modelCalls text frame locals start ready).scan .endOnly frame.functions frame.procedures) =
      (bodyParts modelCalls text frame locals start ready).result := by
    cases initialized : (bodyParts modelCalls text frame locals start ready).initialized with
    | false => simpa only [Bool.false_eq_true, ↓reduceIte] using imports.readBody initialized
    | true => simpa only [↓reduceIte] using imports.bodyTail initialized
  rw (transparency := .default) [selected, imports.endToken, imports.skip, imports.nameAfter, imports.following]
  rfl

/-- The closing name is compared only after its native span checks pass.
Successful installation uses metadata append and hiding at the exact arguments. -/
structure BodyFinishImports (calls : Calls) (text : Source) (outer frame : ParserState)
    (first after : Nat) (parts : BodyParts) : Prop where
  equal : bodyPrefix parts = false →
    calls .equal text first after parts.endFirst parts.endAfter =
      Named.equalName text first after parts.endFirst parts.endAfter
  append : bodyRejected modelCalls text outer first after parts = false →
    calls .appendProcedure frame.procedures ⟨first, after, frame.firstProcedureParameter,
      frame.procedures.parameters.length - frame.firstProcedureParameter + 1⟩ =
    ProcedureBindings.append frame.procedures ⟨first, after, frame.firstProcedureParameter,
      frame.procedures.parameters.length - frame.firstProcedureParameter + 1⟩
  hide : bodyRejected modelCalls text outer first after parts = false →
    calls .hideName text outer.hiding first after = hideName text outer.hiding first after
  nameIs : bodyRejected modelCalls text outer first after parts = false → ∀ operation : Names.Operation,
    calls .nameIs text first after operation.name = Named.nameIs text first after (operation.name.toList.map Char.toNat)

theorem body_finish_imports (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (parts : BodyParts) (imports : BodyFinishImports calls text outer frame first after parts) :
    bodyFinish calls text outer frame first after parts = bodyFinish modelCalls text outer frame first after parts := by
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

def bodyStart (text : Source) (bound : ParserState) : ParserState :=
  {bound with position := fixedAfter text bound.position "begin" true}

structure BodyImports (calls : Calls) (text : Source) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool) : Prop where
  locals : calls .functionLocals text frame arguments = functionLocals text frame arguments
  inputFrame : let locals := functionLocals text frame arguments
    locals.position ≠ 0 → calls .procedureInputFrame text locals = procedureInputFrame text locals
  beginToken : let locals := functionLocals text frame arguments; let bound := procedureInputFrame text locals
    locals.position ≠ 0 → bound.position ≠ 0 →
    calls .take text bound.position (.fixed "begin" true) = fixedAfter text bound.position "begin" true
  prefixReady : let locals := functionLocals text frame arguments; let bound := procedureInputFrame text locals
    locals.position ≠ 0 → bound.position ≠ 0 →
    calls .procedurePrefix text (bodyStart text bound) locals.scalarNames.length =
      procedurePrefix text (bodyStart text bound) locals.scalarNames.length
  parts : let locals := functionLocals text frame arguments; let bound := procedureInputFrame text locals
    let start := bodyStart text bound; let ready := procedurePrefix text start locals.scalarNames.length
    locals.position ≠ 0 → bound.position ≠ 0 → ready.position ≠ 0 →
      BodyPartsImports calls text frame locals start ready
  finish : let locals := functionLocals text frame arguments; let bound := procedureInputFrame text locals
    let start := bodyStart text bound; let ready := procedurePrefix text start locals.scalarNames.length
    locals.position ≠ 0 → bound.position ≠ 0 → ready.position ≠ 0 →
      BodyFinishImports calls text outer frame first after (bodyParts modelCalls text frame locals start ready)

theorem procedureBody_imports (calls : Calls) (text : Source) (outer frame : ParserState) (first after : Nat)
    (arguments : Bool) (imports : BodyImports calls text outer frame first after arguments) :
    procedureBodyBody.eval calls (BodyInput.locals ⟨text, outer, frame, first, after, arguments⟩) =
      procedureBodyAt text outer frame first after arguments := by
  rw [body_denotation, ← body_model_equation]
  dsimp +instances only [bodyEquation]
  have modelLocals : modelCalls .functionLocals = functionLocals := rfl
  have modelFrame : modelCalls .procedureInputFrame = procedureInputFrame := rfl
  have modelPrefix : modelCalls .procedurePrefix = procedurePrefix := rfl
  have modelTake : modelCalls .take = tokenAfter := rfl
  simp +instances only [modelLocals, modelFrame, modelPrefix, modelTake, decide_eq_true_eq]
  rw [imports.locals]
  by_cases localsZero : (functionLocals text frame arguments).position = 0
  · simp only [localsZero, ↓reduceIte]
  · simp only [localsZero, ↓reduceIte]
    rw [imports.inputFrame localsZero]
    by_cases boundZero : (procedureInputFrame text (functionLocals text frame arguments)).position = 0
    · simp only [boundZero, ↓reduceIte]
    · simp only [boundZero, ↓reduceIte]
      rw (transparency := .default) [imports.beginToken localsZero boundZero,
        imports.prefixReady localsZero boundZero]
      let locals := functionLocals text frame arguments
      let bound := procedureInputFrame text locals
      let start := bodyStart text bound
      let ready := procedurePrefix text start locals.scalarNames.length
      change (if ready.position = 0 then invalidState else
        bodyFinish calls text outer frame first after (bodyParts calls text frame locals start ready)) =
        (if ready.position = 0 then invalidState else
        bodyFinish modelCalls text outer frame first after (bodyParts modelCalls text frame locals start ready))
      by_cases readyZero : ready.position = 0
      · simp only [readyZero, ↓reduceIte]
      · simp only [readyZero, ↓reduceIte]
        rw (transparency := .default)
          [body_parts_imports calls text frame locals start ready (imports.parts localsZero boundZero readyZero)]
        exact body_finish_imports calls text outer frame first after _ (imports.finish localsZero boundZero readyZero)

end Silver.Compose.ProcedureDeclarationNative
