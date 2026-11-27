module

public import Silver.ApplicationPackageCallsValidityMeaning
public import Silver.PredicateFunctionCallMeaning
public import Silver.PredicateProcedureTargetMeaning

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages

/-- Reads an input actual on the same incoming flow used by each sibling.
Package formals are scalar here even when the enclosing Main has array views. -/
theorem input_payload_meaning (text : Source) (context : Predicate.Native.Context)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (parameter : PackageBindings.Formal)
    (cursor : Nat) (original : PackageActual) (textValid : Expressions.ValidText text)
    (valid : Predicate.Native.ValidContext text context)
    (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true)
    (bounded : cursor ≤ text.length + 1) (mode : parameter.mode = .input)
    (progress : cursor < (actualPayload modelCalls text context.model input parameter info cursor original).1) :
    ∃ actual, ActualAt text context.model cursor input.scan.facts (inputFormal parameter) actual
        (actualPayload modelCalls text context.model input parameter info cursor original).1 ∧
      actual.Readable context.model.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      actual.check context.names.shape context.model.analysis (context.model.flow input.scan.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (formalType (inputFormal parameter) context.arrayTypes) = true := by
  have flow := (ValidityNative.body_import_domain text context input.scan storage checked).2.2
  have after : (actualPayload modelCalls text context.model input parameter info cursor original).1 =
      actualAfter text context.model cursor input.scan.facts (inputFormal parameter) := by
    simp [actualPayload, mode, modelCalls]
  have accepted : actualAfter text context.model cursor input.scan.facts (inputFormal parameter) ≠ 0 := by
    rw [← after]
    exact Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le cursor) progress)
  rw [after]
  obtain ⟨actual, parsed⟩ := actual_sound textValid valid.1 bounded accepted
  exact ⟨actual, parsed, actual_meaning valid.bounds.normal valid.1 valid.base valid.arrays
    flow.2.compatible flow.1 parsed (by simp [inputFormal])⟩

/-- The native body and Main constructors set elaborating to false. This
checker theorem uses that caller fact to establish copy-in and copy-out typing.
The raw Package_Call_At interpreter also covers elaborating entry contexts. -/
theorem writable_payload_meaning (text : Source) (context : Predicate.Native.Context)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (parameter : PackageBindings.Formal)
    (cursor : Nat) (original : PackageActual)
    (valid : Predicate.Native.ValidContext text context) (body : context.elaborating = false)
    (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true)
    (boundsType : parameter.bounds.Bounded) (writable : parameter.mode ≠ .input)
    (progress : cursor < (actualPayload modelCalls text context.model input parameter info cursor original).1) :
    ProcedureTargetMeaning context.model input.scan.facts (outputFormal parameter)
      (actualPayload modelCalls text context.model input parameter info cursor original).2.target := by
  have flow := (ValidityNative.body_import_domain text context input.scan storage checked).2.2
  have base := valid.base
  rw [body] at base
  have target := actualPayload_writable_progress writable progress
  simp only [actualPayload, writable, ↓reduceIte, modelCalls] at target ⊢
  exact procedureTargetActual_meaning base.toBaseReady valid.booleans.1 flow.2.compatible.count body
    boundsType (Nat.ne_of_gt target)

end Silver.ApplicationPackageCalls
