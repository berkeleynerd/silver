module

public import Silver.PredicateFunctionCallLibraries
public import Silver.FunctionDeclarationOrdinaryEquations

@[expose] public section

namespace Silver.ApplicationPackageActual
open Compose Compose.Expressions Predicate

theorem actual_model_bound (text : Source) (context : Predicate.Native.Context) (position : Nat)
    (facts : ActiveFlow) (formal : FunctionBindings.Formal) (valid : ValidText text)
    (contextValid : Predicate.Native.ValidContext text context) (bounded : ValidCursor text position) :
    Predicate.actualAfter text context.model position facts formal ≤ text.length + 1 := by
  unfold Predicate.actualAfter
  split
  · dsimp only [Predicate.arrayActualAfter]
    split
    · exact Nat.zero_le _
    · exact function_nameAfter_bound text _
  · split
    · exact Predicate.Native.condition_bound text context.model position facts valid contextValid.1 bounded
    · dsimp only
      split
      · exact Nat.zero_le _
      · rename_i accepted
        have nonzero : (Predicate.readScalarInFlow text context.model position facts).after ≠ 0 :=
          fun zero => accepted (.inl zero)
        obtain ⟨expression, parsed⟩ := ScalarExpression.ArrayGrammar.read_sound bounded nonzero
        exact parsed.cursorBounds.2.2

/-- Inherited native source dictionaries for Actual_After. The primitive
meanings are derived from their library links and source definitions below. -/
structure Library where
  composed : Compose.Expressions.Calls
  domain : StateDomain
  inherited : RawHelperEquations composed (domain := domain)
  literals : IntegerLiteral.Native.Calls
  literalSource : IntegerLiteral.Native.Equations literals
  integer : Source → Nat → IntegerLiteral.Result
  integerSource : ∀ text, IntegerLiteral.Native.ValidText text → ∀ position,
    position ≤ text.length + 1 → integer text position = literals.model text position
  predicate : Predicate.Native.Calls
  predicateLinks : Predicate.Native.Libraries.Links predicate composed integer
  predicateDefinitions : Predicate.Native.DefinitionEquations predicate
  predicateContracts : Predicate.Native.Contracts predicate
  imports : FunctionCallNative.Imports
  importLinks : FunctionCallNative.ImportsLinks imports composed predicate
  calls : FunctionCallNative.Calls
  assignment : Source → Predicate.Native.Context → BodyScan → FunctionBindings.Metadata → BodyScan
  definitions : FunctionCallNative.DefinitionEquations imports calls assignment

namespace Library

theorem predicate_meaning (library : Library) : Predicate.Native.HelperMeaning library.predicate :=
  Predicate.Native.Libraries.helper_meaning library.predicate library.composed library.inherited
    library.literals library.literalSource library.integer library.integerSource library.predicateLinks

theorem imports_meaning (library : Library) : FunctionCallNative.ImportsMeaning library.imports :=
  FunctionCallNative.imports_meaning library.inherited library.predicate_meaning
    library.predicateDefinitions library.predicateContracts library.importLinks

/-- The actual native call, on the complete original domain, with the original
dynamic-name fields retained in its context witness. Empty formal intervals,
zero names and rejected actuals are included. -/
theorem actual (library : Library) (text : Source) (context : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : FunctionBindings.Formal)
    (legal : FunctionCallNative.ActualDomain text context position facts formal) :
    library.calls.actual text context position facts formal =
      Predicate.actualAfter text context.model position facts formal := by
  classical
  have interpreted := congrArg (fun fn => fn text context position facts formal)
    (FunctionCallNative.normalized_actual library.imports_meaning library.definitions)
  simpa only [FunctionCallNative.totalizeCalls, FunctionCallNative.modelCalls, legal, ↓reduceIte]
    using interpreted

theorem actual_bound (library : Library) (text : Source) (context : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : FunctionBindings.Formal)
    (legal : FunctionCallNative.ActualDomain text context position facts formal) :
    library.calls.actual text context position facts formal ≤ text.length + 1 := by
  rw [library.actual text context position facts formal legal]
  exact actual_model_bound text context position facts formal
    legal.1.1.1 legal.1.1.2.1 legal.1.1.2.2

end Library

/-- Function_Return_After's own original typed body and its two inherited
callees. No completed return-parser meaning is a field of this interface. -/
structure ReturnLibrary where
  actual : Library
  calls : FunctionDeclarationNative.Calls
  take : calls .take = actual.composed.function .takeToken
  reader : calls .actualAfter = actual.calls.actual
  definition : ∀ text, FunctionBindings.Native.ValidText text → ∀ context scan resultType,
    FunctionDeclarationNative.ReturnInput text context scan resultType →
    calls .returnAfter text context scan resultType =
      FunctionDeclarationNative.returnAfterBody.eval calls
        ({text, context, scan, resultType} : FunctionDeclarationNative.Frame).locals

namespace ReturnLibrary

theorem imports (library : ReturnLibrary) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (scan : BodyScan) (resultType : FunctionTypeResult)
    (legal : FunctionDeclarationNative.ReturnInput text context scan resultType) :
    FunctionDeclarationNative.ReturnImports library.calls text context scan resultType := by
  constructor
  · change library.calls .take text scan.position (.word "return") = tokenAfter text scan.position (.word "return")
    rw [library.take]
    exact interpreted_take library.actual.composed library.actual.inherited text valid
      scan.position _ legal.scan.1 (by unfold ValidToken; decide)
  · rw [library.reader]
    apply library.actual.actual
    exact ⟨⟨⟨valid, legal.context, fixedAfter_result_bound text _ "return" true (by decide)⟩,
      legal.scan.2.2⟩, Nat.zero_le _, Nat.zero_le _, legal.resultType.bounds, Nat.zero_le _⟩

theorem return_after (library : ReturnLibrary) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (scan : BodyScan) (resultType : FunctionTypeResult)
    (legal : FunctionDeclarationNative.ReturnInput text context scan resultType) :
    library.calls .returnAfter text context scan resultType =
      functionReturnAfter text context.model scan resultType := by
  rw [library.definition text valid context scan resultType legal]
  exact FunctionDeclarationNative.returnAfter_imports library.calls text context scan resultType
    (library.imports text valid context scan resultType legal)

theorem model_bound (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (scan : BodyScan) (resultType : FunctionTypeResult)
    (contextValid : Predicate.Native.ValidContext text context) :
    functionReturnAfter text context.model scan resultType ≤ text.length + 1 := by
  exact actual_model_bound text context _ scan.facts _ valid contextValid
    (fixedAfter_result_bound text _ "return" true (by decide))

theorem return_bound (library : ReturnLibrary) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (scan : BodyScan) (resultType : FunctionTypeResult)
    (legal : FunctionDeclarationNative.ReturnInput text context scan resultType) :
    library.calls .returnAfter text context scan resultType ≤ text.length + 1 := by
  rw [library.return_after text valid context scan resultType legal]
  exact model_bound text valid context scan resultType legal.context

end ReturnLibrary
end Silver.ApplicationPackageActual
