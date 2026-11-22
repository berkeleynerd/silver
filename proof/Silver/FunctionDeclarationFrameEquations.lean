module

public import Silver.FunctionDeclarationRecordTypes
public import Silver.FunctionDeclarationImports
public import Silver.FunctionDeclarationDomains
public import Silver.FunctionDeclarationRecursion
public import Silver.ArrayBindingsSourceBridge

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- Each equation has the native record/index domain from its complete checked
header. Append_Parameter and Parameter_Frame_Model admit typed invalid states. -/
structure FrameEquations (calls : Calls) : Prop where
  appendArrayParameterModel : ∀ frame first after typeId, StateRecord frame →
    CursorType first → CursorType after → typeId ≤ ArrayBindings.maxTypes →
    calls .appendArrayParameterModel frame first after typeId =
      appendArrayParameterModelBody.eval calls ({frame, first, after, typeId} : Frame).locals
  appendArrayParameter : ∀ frame first after typeId, StateRecord frame →
    CursorType first → CursorType after → typeId ≤ ArrayBindings.maxTypes →
    calls .appendArrayParameter frame first after typeId = calls .appendArrayParameterModel frame first after typeId
  appendParameter : ∀ frame parameter, StateRecord frame → FunctionBindings.Native.FormalType parameter →
    calls .appendParameter frame parameter = appendParameterBody.eval calls ({frame, parameter} : Frame).locals
  parameterModel : ∀ frame index, StateRecord frame → 0 < index → index ≤ frame.functions.parameters.length + 1 →
    calls .parameterFrameModel frame index = parameterFrameModelBody.eval calls ({frame, index} : Frame).locals
  parameterFrame : ∀ text, FunctionBindings.Native.ValidText text → ∀ frame,
    StateRecord frame → NativeValidState text frame → 0 < frame.firstParameter →
    calls .parameterFrame text frame = calls .parameterFrameModel frame frame.firstParameter

/-- Existing scalar Append correspondence is imported on its written capacity
precondition; no source-name or nonempty-interval condition is added. -/
structure ScalarAppendMeaning (calls : Calls) : Prop where
  append : ∀ names item, names.length < ScalarExpression.maxBindings →
    calls .scalarAppend names item = names ++ [item]

structure ArrayParameterImports (calls : Calls) : Prop where
  validType : ∀ item, ArrayBindings.Native.ArrayTypeType item →
    calls .validArrayType item = decide (ArrayBindings.ValidType item)

/-- The shared array predicate is interpreted from its separately checked
actual source, on bounded intervals including empty and otherwise invalid types. -/
theorem array_parameter_imports {calls : Calls} (arrays : ArrayBindings.Native.Calls)
    (source : ArrayBindings.SourceBridge.InterpretedSource arrays)
    (linked : calls .validArrayType = arrays.validType) : ArrayParameterImports calls where
  validType item typed := by
    rw [linked]
    exact (ArrayBindings.SourceBridge.interpreted_predicates arrays source).validType item typed

theorem interpreted_appendArrayParameter (calls : Calls) (equations : FrameEquations calls)
    (arrays : ArrayParameterImports calls) (frame : ParserState) (first after typeId : Nat)
    (typed : StateRecord frame) (firstBound : CursorType first) (afterBound : CursorType after)
    (typeIdBound : typeId ≤ ArrayBindings.maxTypes) :
    calls .appendArrayParameter frame first after typeId = appendArrayParameter frame first after typeId := by
  rw [equations.appendArrayParameter frame first after typeId typed firstBound afterBound typeIdBound,
    equations.appendArrayParameterModel frame first after typeId typed firstBound afterBound typeIdBound]
  apply appendArrayParameter_imports
  constructor
  intro nonzero bound
  exact arrays.validType _ ((typed.arrayTypes.2 _ (ArrayBindings.arrayType_mem (by omega) bound)).2.2)

theorem interpreted_appendParameter (calls : Calls) (equations : FrameEquations calls)
    (scalar : ScalarAppendMeaning calls) (arrays : ArrayParameterImports calls) (frame : ParserState) (parameter : FunctionBindings.Formal)
    (typed : StateRecord frame) (parameterTyped : FunctionBindings.Native.FormalType parameter) :
    calls .appendParameter frame parameter = appendParameter frame parameter := by
  rw [equations.appendParameter frame parameter typed parameterTyped]
  apply appendParameter_imports
  constructor
  · intro _
    exact interpreted_appendArrayParameter calls equations arrays frame parameter.first parameter.after parameter.typeId
      typed parameterTyped.1 parameterTyped.2.1 parameterTyped.2.2.2
  · intro _ notFull
    apply scalar.append
    have bound := typed.scalars.1
    omega

def parameterFrameEquation (calls : Calls) (frame : ParserState) (index : Nat) : ParserState :=
  if frame.position = 0 then invalidState
  else if index > frame.functions.parameters.length then frame
  else let next := calls .appendParameter frame (FunctionBindings.parameter frame.functions index)
    if next.position = 0 then invalidState else calls .parameterFrameModel next (index + 1)

theorem parameterFrame_denotation (calls : Calls) (frame : ParserState) (index : Nat) :
    parameterFrameModelBody.eval calls ({frame, index} : Frame).locals = parameterFrameEquation calls frame index := by
  simp [parameterFrameModelBody, Expr.eval, apply2, Frame.locals, Locals.set,
    Field.get, parameterFrameEquation]

theorem parameterFrame_model_equation (frame : ParserState) (index : Nat) :
    parameterFrameModel frame index = parameterFrameEquation modelCalls frame index := by
  rw [← parameterFrameModel_model, parameterFrame_denotation]

theorem interpreted_parameterFrameModel (calls : Calls) (equations : FrameEquations calls)
    (scalar : ScalarAppendMeaning calls) (arrays : ArrayParameterImports calls) (frame : ParserState) (index : Nat)
    (typed : StateRecord frame) (positive : 0 < index) (bound : index ≤ frame.functions.parameters.length + 1) :
    calls .parameterFrameModel frame index = parameterFrameModel frame index := by
  rw [equations.parameterModel frame index typed positive bound, parameterFrame_denotation,
    parameterFrame_model_equation]
  dsimp only [parameterFrameEquation, modelCalls]
  by_cases zero : frame.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases beyond : index > frame.functions.parameters.length
    · simp only [beyond, ↓reduceIte]
    · simp only [beyond, ↓reduceIte]
      have member := FunctionBindings.parameter_mem positive (Nat.le_of_not_gt beyond)
      have parameterTyped := typed.functions.2.2.1 _ member
      rw [interpreted_appendParameter calls equations scalar arrays frame _ typed parameterTyped]
      by_cases rejected : (appendParameter frame (FunctionBindings.parameter frame.functions index)).position = 0
      · simp only [rejected, ↓reduceIte]
      · simp only [rejected, ↓reduceIte]
        have same := (appendParameter_functions frame (FunctionBindings.parameter frame.functions index)).resolve_left rejected
        exact interpreted_parameterFrameModel calls equations scalar arrays
          (appendParameter frame (FunctionBindings.parameter frame.functions index)) (index + 1)
          (appendParameter_record frame _ typed parameterTyped) (by omega) (by rw [same]; omega)
termination_by FunctionBindings.maxFormals + 1 - index
decreasing_by
  have capacity := typed.functions.2.1
  omega

theorem interpreted_parameterFrame (calls : Calls) (equations : FrameEquations calls)
    (scalar : ScalarAppendMeaning calls) (arrays : ArrayParameterImports calls) (text : Source) (textValid : FunctionBindings.Native.ValidText text)
    (frame : ParserState) (typed : StateRecord frame) (valid : NativeValidState text frame)
    (positive : 0 < frame.firstParameter) :
    calls .parameterFrame text frame = parameterFrame text frame := by
  rw [equations.parameterFrame text textValid frame typed valid positive]
  exact interpreted_parameterFrameModel calls equations scalar arrays frame frame.firstParameter typed positive
    valid.base.2.2.2.2.2.2.2.2.2.2.1

end Silver.Compose.FunctionDeclarationNative
