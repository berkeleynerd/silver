module

public import Silver.PredicateBooleanArrayBodyHelpers
public import Silver.PredicateNativeHelpers
public import Silver.ComposeEquations

@[expose] public section
namespace Silver.Predicate.BooleanArrayBodyNative
open Compose

variable {domain : Expressions.StateDomain}

def inheritedImports (composed : Expressions.Calls) (native : Native.Calls)
    (body : BodyWrappers.Calls) : Imports where
  skip := composed.function .skip
  nameAfter := composed.function .nameAfter
  scalarLookup := composed.function .scalarLookup
  arrayLookup := native.arrayLookup
  targetAfter := native.booleanArray
  assignment := fun text position => composed.function .takeToken text position (.symbol ":=")
  condition := fun text context position facts => native.condition text context position facts []
  invalid := body.invalidModel

theorem inherited_meaning {composed native body}
    (source : Expressions.RawHelperEquations composed (domain := domain))
    (helpers : Native.HelperMeaning native)
    (definitions : Native.DefinitionEquations native) (contracts : Native.Contracts native)
    (invalid : BodyWrappers.DefinitionEquations body) :
    ImportsMeaning (inheritedImports composed native body) where
  skip text position valid := Expressions.interpreted_skip composed source text valid.1 position valid.2
  nameAfter text position valid := Expressions.interpreted_name composed source text valid.1 position valid.2
  scalarLookup text names first after valid :=
    source.scalarLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  arrayLookup text names first after valid :=
    helpers.arrayLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  targetAfter text context position facts valid :=
    Native.booleanArray_meaning helpers definitions text valid.1.1 context valid.1.2.1
      position valid.1.2.2 facts valid.2
  assignment text position valid :=
    Expressions.interpreted_take composed source text valid.1 position (.symbol ":=") valid.2
      (by unfold Expressions.ValidToken; decide +kernel)
  condition text context position facts valid :=
    Native.condition_of_source_equations helpers definitions contracts text valid.1.1 context valid.1.2.1
      position valid.1.2.2 facts valid.2 [] (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])
  invalid scan capacity := BodyWrappers.invalidModel_meaning invalid scan capacity

theorem inherited_model_definitions
    (source : Expressions.RawHelperEquations Expressions.modelCalls (domain := domain)) :
    DefinitionEquations (inheritedImports Expressions.modelCalls Native.modelCalls BodyWrappers.modelCalls) modelCalls := by
  have normalized := totalize_eq_model (inherited_meaning source Native.model_helper_meaning
    Native.model_definition_equations Native.model_contracts BodyWrappers.model_definitions)
  constructor
  · intro text context position _
    rw [normalized]
    exact (target_model ..).symm
  · intro text context scan _
    rw [normalized]
    change assignmentBody.Sized modelImports (totalizeTarget modelTarget) _
    rw [model_totalizeTarget]
    exact assignment_sized ..
  · intro text context scan _
    rw [normalized]
    change booleanArrayAssignmentBody text context.model scan = assignmentEval modelImports (totalizeTarget modelTarget) _ _ _
    rw [model_totalizeTarget]
    exact (assignment_model ..).symm
  · intros
    rfl

end Silver.Predicate.BooleanArrayBodyNative
