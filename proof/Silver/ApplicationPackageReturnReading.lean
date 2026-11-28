module

public import Silver.ApplicationPackageCompletionResult
public import Silver.PredicateFunctionCallMeaning
public import Silver.PredicateObligations
public import Silver.PackageInterfaces

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackages
open PackageBindings (Metadata Routine)

def resultFormal (item : Routine) : FunctionBindings.Formal :=
  ⟨0, 0, item.resultKind, item.resultBounds, 0⟩

def returnScan (calls : CompletionCalls) (text : Source) (context : ParseContext)
    (info : Metadata) (item : Routine) (input : ApplicationScan) : ApplicationScan :=
  let first := calls.takeToken text input.scan.position (.word "return")
  let after := calls.functionReturnAfter text context input.scan ⟨0, item.resultKind, item.resultBounds, 0⟩
  {input with
    reads := PackageBindings.stateUnion input.reads (calls.stateReads text context info first after)
    scan := {input.scan with position := calls.takeToken text after (.symbol ";")}}

/-- Success uses the original incoming flow, retains its write set, and
rejects every nonempty function write set before the footer can commit it. -/
theorem completionReturn_function {calls : CompletionCalls} {text : Source} {context : ParseContext}
    {info : Metadata} {item : Routine} {input returned : ApplicationScan}
    (kind : item.kind = .function)
    (read : completionReturn calls text context info item input = some returned) :
    returned = returnScan calls text context info item input ∧
      returned.scan.position ≠ 0 ∧ input.writes = PackageBindings.emptyStateSet ∧
      returned.writes = PackageBindings.emptyStateSet ∧ returned.scan.facts = input.scan.facts := by
  simp only [completionReturn, kind, ↓reduceIte] at read
  split at read
  · contradiction
  · rename_i accepted
    cases read
    exact ⟨rfl, fun absent => accepted (Or.inl absent),
      Classical.not_not.mp (fun written => accepted (Or.inr written)),
      Classical.not_not.mp (fun written => accepted (Or.inr written)), rfl⟩

theorem resultFormal_domain (item : Routine) (types : ArrayBindings.TypeEnvironment) :
    formalType (resultFormal item) types = item.resultDomain := by
  simp only [formalType, resultFormal, ne_eq, not_true_eq_false, ↓reduceIte, Routine.resultDomain]
  rfl

/-- The return expression is independently read at the original return
token. The footer cannot turn a rejected expression into an accepted return. -/
theorem completionReturn_function_source {calls : CompletionCalls} {text : Source} {context : ParseContext}
    {info : Metadata} {item : Routine} {input returned : ApplicationScan}
    (take : calls.takeToken = tokenAfter) (returnAfter : calls.functionReturnAfter = functionReturnAfter)
    (textValid : Expressions.ValidText text) (names : Expressions.ValidNames text context.names)
    (kind : item.kind = .function)
    (read : completionReturn calls text context info item input = some returned) :
    ∃ value, ActualAt text context (fixedAfter text input.scan.position "return" true) input.scan.facts
        (resultFormal item) value (functionReturnAfter text context input.scan ⟨0, item.resultKind, item.resultBounds, 0⟩) ∧
      (∀ other after, ActualAt text context (fixedAfter text input.scan.position "return" true) input.scan.facts
        (resultFormal item) other after → other = value) ∧
      returned = returnScan calls text context info item input ∧
      input.writes = PackageBindings.emptyStateSet ∧ returned.writes = PackageBindings.emptyStateSet := by
  obtain ⟨same, present, unwritten, finalWrites, _⟩ := completionReturn_function kind read
  have afterPresent : functionReturnAfter text context input.scan ⟨0, item.resultKind, item.resultBounds, 0⟩ ≠ 0 := by
    rw [same] at present
    change calls.takeToken text (calls.functionReturnAfter text context input.scan
      ⟨0, item.resultKind, item.resultBounds, 0⟩) (.symbol ";") ≠ 0 at present
    rw [take, returnAfter] at present
    exact fixedAfter_nonzero present
  obtain ⟨value, parsed⟩ := actual_sound textValid names
    (fixedAfter_result_bound text input.scan.position "return" true (by decide)) afterPresent
  exact ⟨value, parsed, fun other after otherRead => (actual_unique otherRead parsed).1,
    same, unwritten, finalWrites⟩

/-- Source interpretation supplies a reading; the ordinary frame/flow
invariants then derive readability, the complete result check and all of its
expression-intermediate and subtype obligations. No return-safety premise is used. -/
theorem result_reading_checks {text : Source} {context : ParseContext} {input : BodyScan}
    {item : Routine} {value : ScalarFunctions.Actual} {after : Nat}
    (normal : NamesNormal context.names) (names : Expressions.ValidNames text context.names)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (arrays : context.ArraysReady text)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount input.facts)
    (bounded : input.facts.path.Bounded)
    (read : ActualAt text context (fixedAfter text input.position "return" true) input.facts (resultFormal item) value after) :
    value.Readable context.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      value.check context.names.shape context.analysis (context.flow input.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) item.resultDomain = true ∧
      discharged (actualObligations context.names.shape context.analysis (context.flow input.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) item.resultDomain value) = true := by
  have meaning := actual_meaning normal names base arrays compatible bounded read (by simp [resultFormal])
  rw [resultFormal_domain] at meaning
  exact ⟨meaning.1, meaning.2, actual_obligations_discharge meaning.2⟩

theorem CompletionBodyRead.function_source {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : Metadata} {index : Nat} {item : Routine} {state : InitializationFrame} {result : CompletionResult}
    (read : CompletionBodyRead calls text globals info index item state result)
    (take : calls.takeToken = tokenAfter) (returnAfter : calls.functionReturnAfter = functionReturnAfter)
    (textValid : Expressions.ValidText text)
    (names : Expressions.ValidNames text (completionContextOf calls state).names)
    (kind : item.kind = .function) :
    ∃ value, let input := completionDispatch calls text info item state
      ActualAt text (completionContextOf calls state) (fixedAfter text input.scan.position "return" true)
        input.scan.facts (resultFormal item) value
        (functionReturnAfter text (completionContextOf calls state) input.scan ⟨0, item.resultKind, item.resultBounds, 0⟩) ∧
      input.writes = PackageBindings.emptyStateSet ∧ read.returned.writes = PackageBindings.emptyStateSet := by
  obtain ⟨value, source, _, _, unwritten, returned⟩ :=
    completionReturn_function_source take returnAfter textValid names kind read.readReturn
  exact ⟨value, source, unwritten, returned⟩

end Silver.ApplicationPackageBodies
