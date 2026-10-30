module

public import Silver.PredicateBooleanBodyLibraries
public import Silver.PredicateBasicHelpers
public import Silver.PredicateNativeLibraries
public import Silver.PredicateAdapterEnvironment

@[expose] public section

namespace Silver.Predicate.BasicNative
open Compose

variable {domain : Compose.Expressions.StateDomain}

theorem basicToken_fixed (token : ShellToken) (valid : token ∈ basicTokens) : Adapter.FixedToken token := by
  simp only [basicTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Adapter.FixedToken, ShellToken.word, ShellToken.symbol]

/-- Every token call in the complete Basic_Body rendering satisfies the
fixed-token premise needed to project native token behavior to body semantics. -/
theorem basic_token_calls_fixed :
    ∀ token ∈ basicCommands.tokenCalls, Adapter.FixedToken token :=
  fun token present => basicToken_fixed token (basic_tokens_complete token present)

/-- Every Basic_Body callee is linked to its own typed source definition or
runtime wrapper contract. The complete scalar assignment and String target
meanings are derived from those component definitions. -/
structure Links (primitive : Primitives) (inherited : Compose.Expressions.Calls) (predicate : Native.Calls) : Prop where
  callAfter : primitive.callAfter = inherited.function .callAfter
  associationAfter : primitive.associationAfter = inherited.names.associationAfter
  token : primitive.token = inherited.function .takeToken
  scalarBodies : ∃ scalar body calls,
    FlowReaders.Links inherited scalar primitive.expression ∧
    BodyWrappers.DefinitionEquations body ∧
    ScalarBodyNative.DefinitionEquations (ScalarBodyNative.inheritedImports inherited scalar body) calls ∧
    primitive.target = calls.stringTarget ∧ primitive.scalarTarget = calls.target ∧
    primitive.scalarAssignment = calls.assignment ∧ primitive.invalid = body.invalid
  booleanBodies : ∃ body calls,
    BodyWrappers.DefinitionEquations body ∧
    BooleanBodyNative.DefinitionEquations (BooleanBodyNative.inheritedImports inherited predicate body) calls ∧
    primitive.booleanTarget = calls.target ∧ primitive.booleanAssignment = calls.assignment
  arrayBodies : ∃ scalar calls,
    FlowReaders.Links inherited scalar primitive.expression ∧
    ArrayBodyNative.Links inherited scalar calls ∧
    primitive.arrayTarget = calls.target ∧ primitive.arrayAssignment = calls.assignment
  bodyToken : ∃ models wrappers body,
    Adapter.Wrappers.ModelEquations models body (takeTokenCall := inherited.function .takeToken) ∧
    Adapter.Wrappers.Refinement models wrappers ∧
    primitive.bodyToken = wrappers.token
  fits : ∀ (facts : PathFacts.Native.Context) summary,
    primitive.fits facts.model summary =
      LengthIntervals.Native.fitsBody.eval ({facts, value := summary} : LengthIntervals.Native.Inputs).locals
  sameLength : ∀ (facts : PathFacts.Native.Context) left right,
    primitive.sameLength facts.model left right = LengthIntervals.Native.sameLengthBody.eval
      ({facts, left, right} : LengthIntervals.Native.Inputs).locals
  reject : ∀ facts : PathFacts.Native.Context,
    primitive.reject facts.model =
      (PathFacts.Native.rejectedBody.eval ({facts} : Native.Libraries.PathInputs).locals).model

theorem HelperMeaning.of_inherited {primitive : Primitives} {inherited : Compose.Expressions.Calls} {predicate : Native.Calls}
    (source : Compose.Expressions.RawHelperEquations inherited (domain := domain))
    (predicateHelpers : Native.HelperMeaning predicate)
    (predicateDefinitions : Native.DefinitionEquations predicate) (predicateContracts : Native.Contracts predicate)
    (links : Links primitive inherited predicate) :
    HelperMeaning primitive where
  callAfter text names position operation scalarNames arrays hidden booleans valid := by
    rw [links.callAfter]
    exact Compose.Expressions.interpreted_callAfter inherited source text valid.1 names position operation
      valid.2.2.1 valid.2.1 valid.2.2.2.1 valid.2.2.2.2.1 hidden booleans valid.2.2.2.2.2
  associationAfter text position formal valid bounded := by
    rw [links.associationAfter]
    exact Names.interpreted_association inherited.names source.names text valid position formal bounded
  token text position token valid := by
    rw [links.token, Compose.Expressions.interpreted_take inherited source text valid.1 position token
      valid.2.1 (basicToken_valid token valid.2.2)]
    exact basicToken_model text position token valid.2.2
  expression text context position facts valid := by
    obtain ⟨scalar, body, calls, flow, _⟩ := links.scalarBodies
    exact FlowReaders.linked_string source flow {text,context,position,facts} valid
  target text context position valid := by
    obtain ⟨scalar, body, calls, flow, invalid, definitions, target, _⟩ := links.scalarBodies
    rw [target, definitions.stringTarget text context position valid,
      ScalarBodyNative.totalize_eq_model (ScalarBodyNative.inherited_meaning source flow invalid)]
  bodyToken text context scan token valid := by
    obtain ⟨models, wrappers, body, definitions, refinement, observed⟩ := links.bodyToken
    rw [observed]
    exact Adapter.Wrappers.token_interpreted (Adapter.Wrappers.normalize_tokens source definitions)
      refinement text context scan token
      ⟨valid.1.1.1, valid.1.1.2.1,
        ⟨valid.1.1.2.2, valid.1.2.1, valid.1.2.2⟩,
        basicToken_valid token valid.2⟩ (basicToken_fixed token valid.2)
  invalid scan capacity := by
    obtain ⟨scalar, body, calls, flow, invalid, definitions, target, scalarTarget, assignment, observed⟩ := links.scalarBodies
    rw [observed]
    exact BodyWrappers.invalid_meaning invalid scan capacity
  scalarTarget text context position valid := by
    obtain ⟨scalar, body, calls, flow, invalid, definitions, target, observed, _⟩ := links.scalarBodies
    rw [observed]
    exact ScalarBodyNative.target_meaning (ScalarBodyNative.inherited_meaning source flow invalid)
      definitions text context position valid
  scalarAssignment text context scan valid := by
    obtain ⟨scalar, body, calls, flow, invalid, definitions, target, scalarTarget, observed, _⟩ := links.scalarBodies
    rw [observed]
    exact ScalarBodyNative.assignment_meaning (ScalarBodyNative.inherited_meaning source flow invalid)
      definitions text context scan valid
  booleanTarget text context position valid := by
    obtain ⟨body, calls, invalid, definitions, observed, _⟩ := links.booleanBodies
    rw [observed]
    exact BooleanBodyNative.target_meaning
      (BooleanBodyNative.inherited_meaning source predicateHelpers predicateDefinitions predicateContracts invalid)
      definitions text context position valid
  booleanAssignment text context scan valid := by
    obtain ⟨body, calls, invalid, definitions, _, observed⟩ := links.booleanBodies
    rw [observed]
    exact BooleanBodyNative.assignment_meaning
      (BooleanBodyNative.inherited_meaning source predicateHelpers predicateDefinitions predicateContracts invalid)
      definitions text context scan valid
  arrayTarget text context position valid := by
    obtain ⟨scalar, calls, flow, arrays, observed, _⟩ := links.arrayBodies
    rw [observed]
    exact ArrayBodyNative.linked_target source flow arrays text context position valid
  arrayAssignment text context scan valid := by
    obtain ⟨scalar, calls, flow, arrays, _, observed⟩ := links.arrayBodies
    rw [observed]
    exact ArrayBodyNative.linked_assignment source flow arrays text context scan valid
  fits facts summary := by
    have equation := links.fits (Native.Libraries.reify facts) summary
    simpa only [LengthIntervals.Native.fitsBody_eval,
      LengthIntervals.Native.fits_model, Native.Libraries.reify_model] using equation
  sameLength facts left right := by
    have equation := links.sameLength (Native.Libraries.reify facts) left right
    simpa only [LengthIntervals.Native.sameLengthBody_eval,
      LengthIntervals.Native.sameLength_model, Native.Libraries.reify_model] using equation
  reject facts := by
    have equation := links.reject (Native.Libraries.reify facts)
    simpa only [PathFacts.Native.rejectedBody_eval, Native.Libraries.PathInputs.locals,
      PathFacts.Native.rejected_model, Native.Libraries.reify_model] using equation


/-- A simultaneous witness for the complete callee wiring. The inherited
reader theorem is parameterized by the selected state domain. -/
theorem model_links (source : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain)) :
    Links {modelPrimitives with
      token := Compose.Expressions.modelCalls.function .takeToken
      bodyToken := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).token} Compose.Expressions.modelCalls Native.modelCalls where
  callAfter := rfl
  associationAfter := rfl
  token := rfl
  scalarBodies := by
    have flow : FlowReaders.Links Compose.Expressions.modelCalls (fun text context position facts => Native.modelCalls.scalarInFlow text context position facts []) modelPrimitives.expression :=
      Native.Libraries.model_links.readers.defaults
    let imported := ScalarBodyNative.inheritedImports Compose.Expressions.modelCalls
      (fun text context position facts => Native.modelCalls.scalarInFlow text context position facts []) BodyWrappers.modelCalls
    have normalized : ScalarBodyNative.totalize imported = ScalarBodyNative.modelImports :=
      ScalarBodyNative.totalize_eq_model
        (ScalarBodyNative.inherited_meaning source flow BodyWrappers.model_definitions)
    refine ⟨(fun text context position facts => Native.modelCalls.scalarInFlow text context position facts []), BodyWrappers.modelCalls, ScalarBodyNative.modelCalls,
      flow, BodyWrappers.model_definitions, ?_, rfl, rfl, rfl, rfl⟩
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
  booleanBodies := ⟨BodyWrappers.modelCalls, BooleanBodyNative.modelCalls,
    BodyWrappers.model_definitions, BooleanBodyNative.inherited_model_definitions source, rfl, rfl⟩
  arrayBodies := by
    have flow : FlowReaders.Links Compose.Expressions.modelCalls (fun text context position facts => Native.modelCalls.scalarInFlow text context position facts []) modelPrimitives.expression :=
      Native.Libraries.model_links.readers.defaults
    exact ⟨(fun text context position facts => Native.modelCalls.scalarInFlow text context position facts []), ArrayBodyNative.modelCalls, flow,
      ArrayBodyNative.model_links source flow, rfl, rfl⟩
  bodyToken := ⟨Adapter.Wrappers.modelCalls BodyNative.modelCalls,
    Adapter.Wrappers.modelCalls BodyNative.modelCalls, BodyNative.modelCalls,
    Adapter.Wrappers.model_raw_equations source BodyNative.modelCalls,
    Adapter.Wrappers.model_refinement _, rfl⟩
  fits facts summary := by
    rw [LengthIntervals.Native.fitsBody_eval, LengthIntervals.Native.fits_model]
    rfl
  sameLength facts left right := by
    rw [LengthIntervals.Native.sameLengthBody_eval, LengthIntervals.Native.sameLength_model]
    rfl
  reject facts := by
    rw [PathFacts.Native.rejectedBody_eval]
    exact (PathFacts.Native.rejected_model facts).symm

end Silver.Predicate.BasicNative
