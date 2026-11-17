module

public import Silver.PredicateProcedureCallHelpers
public import Silver.PredicateFunctionCallLibraries
public import Silver.PredicateAdapterEnvironment

@[expose] public section
namespace Silver.Predicate.ProcedureCallNative
open Compose

variable {domain : Compose.Expressions.StateDomain}

/-- Native helper identity and previously checked source interfaces. The
procedure-call meanings themselves are conclusions of DefinitionEquations. -/
structure ImportsLinks (calls : Calls) (inherited : Compose.Expressions.Calls) (predicate : Native.Calls) : Prop where
  markFormal : ∃ associations, AssociationNative.DefinitionEquations associations ∧
    calls .markFormal = associations .markFormal
  skip : calls .skip = predicate.skip
  nameAfter : calls .nameAfter = predicate.nameAfter
  namesLookup : calls .namesLookup = predicate.lookup
  scalarLookup : calls .scalarLookup = predicate.scalarLookup
  booleanLookup : calls .booleanLookup = predicate.booleanLookup
  arrayLookup : calls .arrayLookup = predicate.arrayLookup
  procedureLookup : calls .procedureLookup = inherited.function .procedureLookup
  token : ∀ text position token, TokenDomain text position token →
    calls .token text position token = inherited.function .takeToken text position token
  isEmpty : calls .isEmpty = inherited.function .scalarEmpty
  included : ∃ imported, FunctionCallNative.ImportsLinks imported inherited predicate ∧
    calls .included = imported.included
  targets : ∃ targets, FunctionCallNative.TargetLinks targets inherited predicate ∧
    calls .scalarTarget = targets.scalarTarget ∧ calls .booleanTarget = targets.booleanTarget
  functionActual : ∃ imported functions assignment,
    FunctionCallNative.ImportsLinks imported inherited predicate ∧
    FunctionCallNative.DefinitionEquations imported functions assignment ∧
    calls .functionActual = functions.actual
  nameFree : ∃ step model scan, ProcedureNameNative.FreeDefinitionEquations inherited step model scan ∧
    calls .nameFree = scan ∧ calls .nameFreeModel = model
  association : ∃ associations, AssociationNative.ImportsLinks associations inherited predicate ∧
    AssociationNative.DefinitionEquations associations ∧ calls .association = associations .procedureAssociation
  invalid : ∃ body, BodyWrappers.DefinitionEquations body ∧
    calls .invalid = body.invalid ∧ calls .invalidModel = body.invalidModel
  bodyToken : ∃ models wrappers body,
    Adapter.Wrappers.ModelEquations models body (takeTokenCall := inherited.function .takeToken) ∧
    Adapter.Wrappers.Refinement models wrappers ∧
    ∀ text context scan token, BodyTokenDomain text context scan token →
      calls .bodyToken text context scan token = wrappers.token text context scan token

theorem callToken_valid (token : ShellToken) (valid : token ∈ callTokens) : Compose.Expressions.ValidToken token := by
  simp only [callTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl <;> unfold Compose.Expressions.ValidToken <;> decide +kernel

theorem callToken_fixed (token : ShellToken) (valid : token ∈ callTokens) : Adapter.FixedToken token := by
  simp only [callTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl <;> simp [Adapter.FixedToken, ShellToken.symbol]

theorem callToken_model (text : Source) (position : Nat) (token : ShellToken) (valid : token ∈ callTokens) :
    fixedAfter text position (Compose.Expressions.spelling token) (Compose.Expressions.isWord token) = tokenAfter text position token := by
  simp only [callTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl <;> rfl

theorem imports_meaning {calls inherited predicate}
    (source : Compose.Expressions.RawHelperEquations inherited (domain := domain))
    (helpers : Native.HelperMeaning predicate) (defs : Native.DefinitionEquations predicate)
    (contracts : Native.Contracts predicate) (links : ImportsLinks calls inherited predicate) :
    ImportsMeaning calls where
  markFormal := by
    classical
    funext seen formal
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨associations, definitions, observed⟩ := links.markFormal
      rw [observed]
      exact AssociationNative.markFormal_meaning definitions seen formal valid
    · rfl
  skip := by
    classical
    funext text position
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.skip]
      exact helpers.skip text valid.1 position valid.2
    · rfl
  nameAfter := by
    classical
    funext text position
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.nameAfter]
      exact helpers.name text valid.1 position valid.2
    · rfl
  namesLookup := by
    classical
    funext text names first after
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.namesLookup]
      exact helpers.lookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
    · rfl
  scalarLookup := by
    classical
    funext text names first after
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.scalarLookup]
      exact helpers.scalarLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
    · rfl
  booleanLookup := by
    classical
    funext text names first after
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.booleanLookup]
      exact helpers.booleanLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
    · rfl
  arrayLookup := by
    classical
    funext text names first after
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.arrayLookup]
      exact helpers.arrayLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
    · rfl
  procedureLookup := by
    classical
    funext text catalog first after
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.procedureLookup]
      exact source.procedureLookup text valid.1 catalog first after valid.2.1 valid.2.2.1 valid.2.2.2
    · rfl
  token := by
    classical
    funext text position token
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.token text position token valid,
        Compose.Expressions.interpreted_take inherited source text valid.1.1 position token valid.1.2
          (callToken_valid token valid.2)]
      exact callToken_model text position token valid.2
    · rfl
  isEmpty := by
    classical
    funext bounds
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      rw [links.isEmpty]
      exact source.scalarEmpty bounds valid
    · rfl
  included := by
    classical
    funext left right
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨imported, importedLinks, observed⟩ := links.included
      rw [observed]
      exact (FunctionCallNative.imports_meaning source helpers defs contracts importedLinks).included left right valid
    · rfl
  scalarTarget := by
    classical
    funext text context position
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨targets, targetLinks, observed, _⟩ := links.targets
      rw [observed]
      exact (FunctionCallNative.targets_meaning source helpers defs contracts targetLinks).scalar text context position valid
    · rfl
  booleanTarget := by
    classical
    funext text context position
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨targets, targetLinks, _, observed⟩ := links.targets
      rw [observed]
      exact (FunctionCallNative.targets_meaning source helpers defs contracts targetLinks).boolean text context position valid
    · rfl
  functionActual := by
    classical
    funext text context position facts parameter
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨imported, functions, assignment, importedLinks, definitions, observed⟩ := links.functionActual
      rw [observed]
      have result := congrFun (congrFun (congrFun (congrFun (congrFun
        (FunctionCallNative.normalized_actual
          (FunctionCallNative.imports_meaning source helpers defs contracts importedLinks) definitions)
        text) context) position) facts) parameter
      change functions.actual text context position facts parameter =
        actualAfter text context.model position facts parameter
      simpa only [FunctionCallNative.totalizeCalls, FunctionCallNative.modelCalls, valid, ↓reduceIte] using result
    · rfl
  nameFree := by
    classical
    funext text position after targetFirst targetAfter
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨step, model, scan, definitions, observed, _⟩ := links.nameFree
      rw [observed]
      exact ProcedureNameNative.interpreted_free inherited source step model scan definitions text
        position after targetFirst targetAfter valid
    · rfl
  nameFreeModel := by
    classical
    funext text position after targetFirst targetAfter
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨step, model, scan, definitions, _, observed⟩ := links.nameFree
      rw [observed]
      exact ProcedureNameNative.interpreted_freeModel inherited source step model scan definitions text
        position after targetFirst targetAfter valid
    · rfl
  association := by
    classical
    funext text position catalog first last ordinal named
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨associations, imported, definitions, observed⟩ := links.association
      rw [observed]
      exact AssociationNative.procedureAssociation_meaning source helpers imported definitions
        text position catalog first last ordinal named valid
    · rfl
  invalid := by
    classical
    funext scan
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨body, definitions, observed, _⟩ := links.invalid
      rw [observed]
      exact BodyWrappers.invalid_meaning definitions scan valid
    · rfl
  invalidModel := by
    classical
    funext scan
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨body, definitions, _, observed⟩ := links.invalid
      rw [observed]
      exact BodyWrappers.invalidModel_meaning definitions scan valid
    · rfl
  bodyToken := by
    classical
    funext text context scan token
    dsimp only [totalizeCalls]
    split
    · rename_i valid
      obtain ⟨models, wrappers, body, definitions, refinement, observed⟩ := links.bodyToken
      rw [observed text context scan token valid]
      exact Adapter.Wrappers.token_interpreted (Adapter.Wrappers.normalize_tokens source definitions)
        refinement text context scan token
        ⟨valid.1.1.1, valid.1.1.2.1, ⟨valid.1.1.2.2, valid.1.2.1, valid.1.2.2⟩,
          callToken_valid token valid.2⟩ (callToken_fixed token valid.2)
    · rfl

structure Links (callee : Source → Native.Context → Nat → ProcedureBindings.Metadata → Nat)
    (call : Source → Native.Context → BodyScan → ProcedureBindings.Metadata → BodyScan)
    (inherited : Compose.Expressions.Calls) (predicate : Native.Calls) : Prop where
  source : ∃ calls, ImportsLinks calls inherited predicate ∧ DefinitionEquations calls ∧
    callee = calls .callee ∧ call = calls .call

theorem linked_callee {callee call inherited predicate}
    (source : Compose.Expressions.RawHelperEquations inherited (domain := domain))
    (helpers : Native.HelperMeaning predicate) (defs : Native.DefinitionEquations predicate)
    (contracts : Native.Contracts predicate) (links : Links callee call inherited predicate)
    (text : Source) (context : Native.Context) (position : Nat) (catalog : ProcedureBindings.Metadata)
    (valid : ScalarBodyNative.TargetDomain text context position)
    (metadata : ProcedureBindings.ValidMetadata text catalog) :
    callee text context position catalog = procedureCalleeAt text context.model position catalog := by
  obtain ⟨calls, imported, definitions, observed, _⟩ := links.source
  rw [observed]
  exact callee_meaning (imports_meaning source helpers defs contracts imported) definitions
    text context position catalog ⟨valid,metadata⟩

theorem linked_call {callee call inherited predicate}
    (source : Compose.Expressions.RawHelperEquations inherited (domain := domain))
    (helpers : Native.HelperMeaning predicate) (defs : Native.DefinitionEquations predicate)
    (contracts : Native.Contracts predicate) (links : Links callee call inherited predicate)
    (text : Source) (context : Native.Context) (scan : BodyScan) (catalog : ProcedureBindings.Metadata)
    (valid : ScalarBodyNative.AssignmentDomain text context scan)
    (metadata : ProcedureBindings.ValidMetadata text catalog) :
    call text context scan catalog = procedureCallBody text context.model scan catalog := by
  obtain ⟨calls, imported, definitions, _, observed⟩ := links.source
  rw [observed]
  exact call_meaning (imports_meaning source helpers defs contracts imported) definitions
    text context scan catalog ⟨valid,metadata⟩

theorem model_imports_links
    (source : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain)) :
    ImportsLinks modelCalls Compose.Expressions.modelCalls Native.modelCalls where
  markFormal := ⟨AssociationNative.modelCalls, AssociationNative.model_definitions, rfl⟩
  skip := rfl
  nameAfter := rfl
  namesLookup := rfl
  scalarLookup := rfl
  booleanLookup := rfl
  arrayLookup := rfl
  procedureLookup := rfl
  token text position token valid := by
    have member := valid.2
    simp only [callTokens, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl <;> rfl
  isEmpty := rfl
  included := ⟨_, FunctionCallNative.model_imports_links, rfl⟩
  targets := ⟨_, FunctionCallNative.model_target_links source, rfl, rfl⟩
  functionActual := ⟨_, FunctionCallNative.modelCalls, _, FunctionCallNative.model_imports_links,
    FunctionCallNative.model_definitions_of_meaning
      (FunctionCallNative.imports_meaning source Native.model_helper_meaning
        Native.model_definition_equations Native.model_contracts FunctionCallNative.model_imports_links), rfl⟩
  nameFree := ⟨_, _, _, ProcedureNameNative.model_definitions, rfl, rfl⟩
  association := ⟨AssociationNative.modelCalls, AssociationNative.model_imports_links,
    AssociationNative.model_definitions, rfl⟩
  invalid := ⟨_, BodyWrappers.model_definitions, rfl, rfl⟩
  bodyToken := by
    refine ⟨_, _, BodyNative.modelCalls, Adapter.Wrappers.model_raw_equations source _,
      Adapter.Wrappers.model_refinement _, ?_⟩
    intro text context scan token valid
    exact (Adapter.Wrappers.token_interpreted (Adapter.Wrappers.model_equations _)
      (Adapter.Wrappers.model_refinement _) text context scan token
      ⟨valid.1.1.1, valid.1.1.2.1, ⟨valid.1.1.2.2, valid.1.2.1, valid.1.2.2⟩,
        callToken_valid token valid.2⟩ (callToken_fixed token valid.2)).symm

theorem model_links
    (source : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain)) :
    Links (fun text context position catalog => procedureCalleeAt text context.model position catalog)
      (fun text context scan catalog => procedureCallBody text context.model scan catalog)
      Compose.Expressions.modelCalls Native.modelCalls :=
  ⟨⟨modelCalls, model_imports_links source, model_definitions, rfl, rfl⟩⟩

end Silver.Predicate.ProcedureCallNative
