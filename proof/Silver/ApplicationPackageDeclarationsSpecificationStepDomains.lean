module

public import Silver.ApplicationPackageDeclarationsSpecificationObjectDomains

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

theorem specification_routine_framed (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (framed : ReaderFrame text state.exports) :
    SpecificationStepFramed text (specificationRoutine (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationRoutine, modelSpecificationCalls]
  split
  · trivial
  · apply continue_specification_framed
    exact state_type_specification_header framed.typed _ _

theorem specification_subtype_framed (reader : BooleanElaboration.Native.Reader) {text : Source}
    (valid : ValidText text) (state : SpecificationState) (framed : ReaderFrame text state.exports) :
    SpecificationStepFramed text (specificationSubtype (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationSubtype, modelSpecificationCalls]
  split
  · trivial
  · rename_i present
    split
    · trivial
    · unfold appendExport
      apply continue_specification_framed
      exact (specification_subtype_base valid state.exports framed false present).typed

theorem specification_object_framed (reader : BooleanElaboration.Native.Reader) {text : Source}
    (valid : ValidText text) (state : SpecificationState) (framed : ReaderFrame text state.exports) :
    SpecificationStepFramed text (specificationObject (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationObject, modelSpecificationCalls]
  split
  · trivial
  · rename_i accepted
    have present : (objectStep (modelObjectCalls reader) text state.exports state.info false).frame.position ≠ 0 :=
      fun missing => accepted (by simp only [missing, decide_true, Bool.true_or])
    unfold appendExport
    apply continue_specification_framed
    exact (objectStep_specification_base reader valid state.exports framed state.info false present).typed

theorem specification_step_framed (reader : BooleanElaboration.Native.Reader) {text : Source}
    (valid : ValidText text) (state : SpecificationState) (framed : ReaderFrame text state.exports) :
    SpecificationStepFramed text (specificationStep (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationStep]
  split
  · exact framed
  · split
    · exact specification_routine_framed reader text state framed
    · split
      · trivial
      · split
        · exact specification_subtype_framed reader valid state framed
        · exact specification_object_framed reader valid state framed

end Silver.ApplicationPackageDeclarations
