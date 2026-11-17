module

public import Silver.PredicateBasicEquations
public import Silver.PredicateProcedureCallProperties

@[expose] public section

namespace Silver.Predicate.BasicNative

/-- The Result local is constrained by the input extent. Check every executed
assignment, retaining imperative return and branch behavior. -/
def Command.Sized (primitive : Primitives) (frame : Frame) (next : Frame → Prop) : Command → Prop
  | .nothing => next frame
  | .update value => (value.eval primitive frame).count = frame.scan.count ∧
      next {frame with result := value.eval primitive frame}
  | .expression => next {frame with value := primitive.expression frame.text frame.context frame.result.position frame.result.facts}
  | .character => next {frame with
      characterValue := primitive.character frame.text frame.result.position
        frame.context.names (primitive.readingNames frame.context frame.result.facts) frame.context.arrayNames}
  | .indexed => next {frame with
      characterValue := primitive.indexed frame.text frame.scan.position
        frame.context.names (primitive.readingNames frame.context frame.result.facts)
        frame.context.arrayNames [] false true}
  | .target => next {frame with target := primitive.target frame.text frame.context frame.result.position}
  | .returnInvalid | .returnResult => True
  | .sequence first second => first.Sized primitive frame (fun updated => second.Sized primitive updated next)
  | .choose test yes no => if test.eval primitive frame then yes.Sized primitive frame next else no.Sized primitive frame next

def SizedBasic (primitive : Primitives) (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata := {})
    (procedures : ProcedureBindings.Metadata := {}) : Prop :=
  scan.count ≤ ScalarExpression.maxBindings ∧
    basicCommands.Sized primitive ⟨text,context,scan,scan,{},{},{},catalog,procedures⟩ (fun _ => True)

private theorem callAssignment_count (text : Source) (context : ParseContext)
    (scan : BodyScan) (catalog : FunctionBindings.Metadata) :
    (callAssignmentBody text context scan catalog).count = scan.count := by
  unfold callAssignmentBody callAssignmentResult
  repeat' first | split | (simp only [invalidBody, BodyScan.count, ActiveFlow.invalid_count,
    ActiveFlow.replace_count])

private theorem model_update_count (frame : Frame) (value : Update) :
    (value.eval modelPrimitives frame).count = frame.result.count := by
  cases value <;> try rfl
  · dsimp only [Update.eval]
    split
    · exact callAssignment_count ..
    · split
      · dsimp only [modelPrimitives, booleanAssignmentBody]
        split <;> rfl
      · exact scalarAssignment_count ..
  · exact procedureCallBody_count ..
  · exact scalarAssignment_count ..
  · dsimp only [Update.eval, modelPrimitives, booleanAssignmentBody]
    split <;> rfl
  · dsimp only [Update.eval, modelPrimitives, arrayAssignmentBody]
    split <;> rfl
  · dsimp only [Update.eval, modelPrimitives, booleanArrayAssignmentBody]
    split <;> rfl

private theorem model_command_sized (command : Command) (frame : Frame)
    (same : frame.result.count = frame.scan.count) (next : Frame → Prop)
    (continuation : ∀ frame, frame.result.count = frame.scan.count → next frame) :
    command.Sized modelPrimitives frame next := by
  induction command generalizing frame next with
  | nothing => exact continuation frame same
  | update value =>
      exact ⟨(model_update_count frame value).trans same,
        continuation _ ((model_update_count frame value).trans same)⟩
  | expression => exact continuation _ same
  | character => exact continuation _ same
  | indexed => exact continuation _ same
  | target => exact continuation _ same
  | returnInvalid | returnResult => trivial
  | sequence first second firstIH secondIH =>
      exact firstIH frame same _ (fun updated count => secondIH updated count next continuation)
  | choose test yes no yesIH noIH =>
      simp only [Command.Sized]
      split
      · exact yesIH frame same next continuation
      · exact noIH frame same next continuation

theorem model_sizedBasic (text : Source) (context : Native.Context) (scan : BodyScan)
    (capacity : scan.count ≤ ScalarExpression.maxBindings)
    (catalog : FunctionBindings.Metadata := {})
    (procedures : ProcedureBindings.Metadata := {}) : SizedBasic modelPrimitives text context scan catalog procedures :=
  ⟨capacity, model_command_sized basicCommands _ rfl _ (fun _ _ => trivial)⟩

end Silver.Predicate.BasicNative
