module

public import Silver.PredicateFunctionCallHelpers
public import Silver.PredicateAssociationLibraries
public import Silver.PredicateScalarBodyHelpers
public import Silver.FunctionBindingsSourceBridge
public import Silver.PredicateNativeHelpers
public import Silver.PredicateNativeLibraries
public import Silver.PredicateBooleanBodyLibraries

@[expose] public section
namespace Silver.Predicate.FunctionCallNative
open Compose FunctionBindings

variable {domain : Compose.Expressions.StateDomain}

/-- Exact callee wiring for the new call trees. Range containment is interpreted
from its own checked expression, rather than assumed as a parser result. -/
structure ImportsLinks (imports : Imports) (composed : Compose.Expressions.Calls)
    (predicate : Native.Calls) : Prop where
  markFormal : ∃ associations, AssociationNative.DefinitionEquations associations ∧
    imports.markFormal = associations .markFormal
  skip : imports.skip = predicate.skip
  nameAfter : imports.nameAfter = predicate.nameAfter
  namesLookup : imports.namesLookup = predicate.lookup
  scalarLookup : imports.scalarLookup = predicate.scalarLookup
  booleanLookup : imports.booleanLookup = predicate.booleanLookup
  arrayLookup : imports.arrayLookup = predicate.arrayLookup
  functions : ∃ calls, FunctionBindings.SourceBridge.InterpretedSource calls ∧
    imports.functionLookup = calls.lookup
  token : imports.token = composed.function .takeToken
  condition : imports.condition = fun text context position facts => predicate.condition text context position facts []
  scalar : imports.scalar = fun text context position facts => predicate.scalarInFlow text context position facts []
  isEmpty : imports.isEmpty = composed.function .scalarEmpty
  included : ∀ left right, left.Bounded → right.Bounded →
    imports.included left right = includedBody.eval imports modelCalls {intervalValue := left, intervalBounds := right}
  invalid : ∃ body, BodyWrappers.DefinitionEquations body ∧ imports.invalid = body.invalidModel
  association : ∃ associations, AssociationNative.ImportsLinks associations composed predicate ∧
    AssociationNative.DefinitionEquations associations ∧ imports.association = associations .functionAssociation

theorem imports_meaning {imports composed predicate}
    (source : Compose.Expressions.RawHelperEquations composed (domain := domain))
    (helpers : Native.HelperMeaning predicate) (defs : Native.DefinitionEquations predicate)
    (contracts : Native.Contracts predicate) (links : ImportsLinks imports composed predicate) :
    ImportsMeaning imports where
  markFormal seen formal valid := by
    obtain ⟨associations, definitions, observed⟩ := links.markFormal
    rw [observed]
    exact AssociationNative.markFormal_meaning definitions seen formal valid
  skip text position valid := by
    rw [links.skip]
    exact helpers.skip text valid.1 position valid.2
  nameAfter text position valid := by
    rw [links.nameAfter]
    exact helpers.name text valid.1 position valid.2
  namesLookup text names first after valid := by
    rw [links.namesLookup]
    exact helpers.lookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  scalarLookup text names first after valid := by
    rw [links.scalarLookup]
    exact helpers.scalarLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  booleanLookup text names first after valid := by
    rw [links.booleanLookup]
    exact helpers.booleanLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  arrayLookup text names first after valid := by
    rw [links.arrayLookup]
    exact helpers.arrayLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  functionLookup text catalog first after valid := by
    obtain ⟨calls, interpreted, observed⟩ := links.functions
    rw [observed]
    exact (FunctionBindings.SourceBridge.interpreted_complete calls interpreted).lookup
      text valid.1 catalog valid.2.1 first after valid.2.2.1 valid.2.2.2
  token text position token valid := by
    have member := valid.2
    simp only [callTokens, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl <;>
      rw [links.token, Compose.Expressions.interpreted_take composed source text valid.1.1 position _ valid.1.2
        (by unfold Compose.Expressions.ValidToken; decide +kernel)] <;> rfl
  condition text context position facts valid := by
    rw [links.condition]
    exact Native.condition_of_source_equations helpers defs contracts text valid.1.1 context valid.1.2.1
      position valid.1.2.2 facts valid.2 [] (by simp [ArrayBindings.ValidInitials])
  scalar text context position facts valid := by
    rw [links.scalar]
    exact helpers.scalarInFlow text valid.1.1 context valid.1.2.1 position facts valid.1.2.2 valid.2 []
      (by simp [ArrayBindings.ValidInitials])
  isEmpty bounds valid := by
    rw [links.isEmpty]
    exact source.scalarEmpty bounds valid
  included left right valid := by
    rw [links.included left right valid.1 valid.2]
    calc
      _ = includedBody.eval modelImports modelCalls {intervalValue := left, intervalBounds := right} := by
        simp only [includedBody, Expr.eval, links.isEmpty,
          source.scalarEmpty left valid.1, source.scalarEmpty right valid.2, modelImports]
        rfl
      _ = _ := included_model left right
  invalid scan valid := by
    obtain ⟨body, definitions, observed⟩ := links.invalid
    rw [observed]
    exact BodyWrappers.invalidModel_meaning definitions scan valid

  association text position catalog first last ordinal named valid := by
    obtain ⟨associations, imported, definitions, observed⟩ := links.association
    rw [observed]
    exact AssociationNative.functionAssociation_meaning source helpers imported definitions
      text position catalog first last ordinal named valid

/-- Scalar and Boolean assignment targets already have separately checked
source definitions. The two predicates retain their complete native domains. -/
structure TargetLinks (calls : Calls) (composed : Compose.Expressions.Calls) (predicate : Native.Calls) : Prop where
  scalar : ∃ scalar string body targets,
    FlowReaders.Links composed scalar string ∧ BodyWrappers.DefinitionEquations body ∧
    ScalarBodyNative.DefinitionEquations (ScalarBodyNative.inheritedImports composed scalar body) targets ∧
    calls.scalarTarget = targets.target
  boolean : ∃ body targets,
    BodyWrappers.DefinitionEquations body ∧
    BooleanBodyNative.DefinitionEquations (BooleanBodyNative.inheritedImports composed predicate body) targets ∧
    calls.booleanTarget = targets.target

theorem targets_meaning {calls composed predicate}
    (source : Compose.Expressions.RawHelperEquations composed (domain := domain))
    (helpers : Native.HelperMeaning predicate) (defs : Native.DefinitionEquations predicate)
    (contracts : Native.Contracts predicate) (links : TargetLinks calls composed predicate) :
    TargetsMeaning calls where
  scalar text context position valid := by
    obtain ⟨scalar, string, body, targets, flow, invalid, definitions, observed⟩ := links.scalar
    rw [observed]
    exact ScalarBodyNative.target_meaning (ScalarBodyNative.inherited_meaning source flow invalid)
      definitions text context position valid
  boolean text context position valid := by
    obtain ⟨body, targets, invalid, definitions, observed⟩ := links.boolean
    rw [observed]
    exact BooleanBodyNative.target_meaning (BooleanBodyNative.inherited_meaning source helpers defs contracts invalid)
      definitions text context position valid

structure Links (assignment : Source → Native.Context → BodyScan → Metadata → BodyScan)
    (composed : Compose.Expressions.Calls) (predicate : Native.Calls) : Prop where
  source : ∃ imports calls,
    ImportsLinks imports composed predicate ∧ TargetLinks calls composed predicate ∧
    DefinitionEquations imports calls assignment

theorem linked_assignment {assignment composed predicate}
    (source : Compose.Expressions.RawHelperEquations composed (domain := domain))
    (helpers : Native.HelperMeaning predicate) (defs : Native.DefinitionEquations predicate)
    (contracts : Native.Contracts predicate) (links : Links assignment composed predicate)
    (text : Source) (context : Native.Context) (scan : BodyScan) (catalog : Metadata)
    (valid : FunctionAssignmentDomain text context scan catalog) :
    assignment text context scan catalog = callAssignmentBody text context.model scan catalog := by
  obtain ⟨imports, calls, imported, targets, definitions⟩ := links.source
  exact assignment_meaning (imports_meaning source helpers defs contracts imported) definitions
    (targets_meaning source helpers defs contracts targets) text context scan catalog valid


theorem model_imports_links :
    ImportsLinks {modelImports with token := Compose.Expressions.modelCalls.function .takeToken}
      Compose.Expressions.modelCalls Native.modelCalls where
  markFormal := ⟨AssociationNative.modelCalls, AssociationNative.model_definitions, rfl⟩
  skip := rfl
  nameAfter := rfl
  namesLookup := rfl
  scalarLookup := rfl
  booleanLookup := rfl
  arrayLookup := rfl
  functions := ⟨FunctionBindings.Native.modelCalls, FunctionBindings.SourceBridge.model_interpreted, rfl⟩
  token := rfl
  condition := rfl
  scalar := rfl
  isEmpty := rfl
  included left right _ _ := (included_model left right).symm
  invalid := ⟨BodyWrappers.modelCalls, BodyWrappers.model_definitions, rfl⟩
  association := ⟨AssociationNative.modelCalls, AssociationNative.model_imports_links,
    AssociationNative.model_definitions, rfl⟩

theorem model_target_links
    (source : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain)) :
    TargetLinks modelCalls Compose.Expressions.modelCalls Native.modelCalls where
  scalar := by
    have flow := Native.Libraries.model_links.readers.defaults
    let scalar := fun text context position facts => Native.modelCalls.scalarInFlow text context position facts []
    let string := fun text context position facts => Native.modelCalls.stringInFlow text context position facts []
    let imported := ScalarBodyNative.inheritedImports Compose.Expressions.modelCalls scalar BodyWrappers.modelCalls
    have normalized : ScalarBodyNative.totalize imported = ScalarBodyNative.modelImports :=
      ScalarBodyNative.totalize_eq_model (ScalarBodyNative.inherited_meaning source flow BodyWrappers.model_definitions)
    refine ⟨scalar, string, BodyWrappers.modelCalls, ScalarBodyNative.modelCalls,
      flow, BodyWrappers.model_definitions, ?_, rfl⟩
    exact {
      target := fun text context position _ => by
        rw [normalized]
        exact (ScalarBodyNative.targetEval_model ..).symm
      stringTarget := fun _ _ _ _ => by rw [normalized]; rfl
      assignmentSized := fun text context scan _ => by
        rw [normalized]
        exact ScalarBodyNative.assignmentEval_model_count ..
      assignmentModel := fun text context scan _ => by
        rw [normalized]
        exact (ScalarBodyNative.assignmentEval_model ..).symm
      assignment := fun _ _ _ _ => rfl }
  boolean := ⟨BodyWrappers.modelCalls, BooleanBodyNative.modelCalls, BodyWrappers.model_definitions,
    BooleanBodyNative.inherited_model_definitions source, rfl⟩

theorem model_links
    (source : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain)) :
    Links (fun text context scan catalog => callAssignmentBody text context.model scan catalog)
      Compose.Expressions.modelCalls Native.modelCalls := by
  refine ⟨⟨_, modelCalls, model_imports_links, model_target_links source, ?_⟩⟩
  exact model_definitions_of_meaning (imports_meaning source Native.model_helper_meaning
    Native.model_definition_equations Native.model_contracts model_imports_links)

end Silver.Predicate.FunctionCallNative
