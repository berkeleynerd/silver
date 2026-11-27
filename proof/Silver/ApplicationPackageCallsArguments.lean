module

public import Silver.ApplicationPackageCallsActualOrder
public import Silver.ApplicationPackageCallsActualMeaning

@[expose] public section

namespace Silver.ApplicationPackageCalls

open Compose Predicate ApplicationPackages

/-- The semantic argument paired with a physical row of the native call,
including the author's original source span and the incoming flow shared by
all sibling actuals. -/
inductive ArgumentAt (text : Source) (context : Predicate.Native.Context) (input : ApplicationScan)
    (parameter : PackageBindings.Formal) (row : PackageActual) : ScalarProcedures.Actual → Prop
  | value {actual} : parameter.mode = .input →
      ActualAt text context.model row.first input.scan.facts (inputFormal parameter) actual row.after →
      actual.Readable context.model.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) →
      actual.check context.names.shape context.model.analysis (context.model.flow input.scan.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (formalType (inputFormal parameter) context.arrayTypes) = true →
      ArgumentAt text context input parameter row (.value actual)
  | target : parameter.mode ≠ .input →
      procedureTargetActual text context.model row.first input.scan.facts (outputFormal parameter) = row.target →
      row.after = row.target.after →
      ProcedureTargetMeaning context.model input.scan.facts (outputFormal parameter) row.target →
      ArgumentAt text context input parameter row (.target (procedureTargetIdentity context.model row.target))

private theorem symbol_end_bound (text : Source) (position : Nat) (spelling : String)
    (nonempty : 0 < spelling.toList.length) : modelCalls.take text position (.symbol spelling) ≤ text.length + 1 :=
  fixedAfter_result_bound text position spelling false nonempty

theorem ActualSourceStep.cursor_bounds {text context input info item ordinal before after entry}
    (step : ActualSourceStep modelCalls text context input info item ordinal before after entry)
    (beforeBound : before.cursor ≤ text.length + 1) :
    entry.2.first ≤ text.length + 1 ∧ after.cursor ≤ text.length + 1 := by
  constructor
  · have selection := step.association
    dsimp only [actualAssociation] at selection
    split at selection
    · have firstEq := congrArg (Option.map (fun p : Nat × Bool × Nat => p.2.2)) selection
      simp only [Option.map_some, Option.some.injEq] at firstEq
      rw [← firstEq]
      exact symbol_end_bound text _ "=>" (by decide)
    · split at selection
      · cases selection
      · have firstEq := congrArg (Option.map (fun p : Nat × Bool × Nat => p.2.2)) selection
        simp only [Option.map_some, Option.some.injEq] at firstEq
        exact firstEq ▸ beforeBound
  · rw [step.separator]
    split <;> exact symbol_end_bound text _ _ (by decide)

theorem ActualSourceStep.argument {text : Source} {context : Predicate.Native.Context}
    {input info item ordinal before after entry}
    (step : ActualSourceStep modelCalls text context.model input info item ordinal before after entry)
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true)
    (beforeBound : before.cursor ≤ text.length + 1) (bounds : (info.parameterAt entry.1).bounds.Bounded) :
    ∃ argument, ArgumentAt text context input (info.parameterAt entry.1) entry.2 argument := by
  let parameter := info.parameterAt entry.1
  let original := {before.actual entry.1 with first := entry.2.first}
  let parsed := actualPayload modelCalls text context.model input parameter info entry.2.first original
  have positions : entry.2.after = parsed.1 ∧ entry.2.target = parsed.2.target := step.payload
  have firstBound := (step.cursor_bounds beforeBound).1
  have progress : entry.2.first < parsed.1 := positions.1 ▸ step.progress
  by_cases inputMode : parameter.mode = .input
  · obtain ⟨actual, source, readable, fits⟩ :=
      input_payload_meaning text context input info parameter entry.2.first original textValid valid
        storage checked firstBound inputMode progress
    exact ⟨.value actual, .value inputMode (positions.1 ▸ source) readable fits⟩
  · have interpreted := writable_payload_meaning text context input info parameter entry.2.first original
      valid body storage checked bounds inputMode progress
    have targetEq : procedureTargetActual text context.model entry.2.first input.scan.facts
        (outputFormal parameter) = entry.2.target := by
      rw [positions.2]
      simp only [parsed, actualPayload, inputMode, ↓reduceIte, modelCalls]
    have ends : entry.2.after = entry.2.target.after := by
      rw [positions.1, positions.2]
      simp only [parsed, actualPayload, inputMode, ↓reduceIte]
    exact ⟨_, .target inputMode targetEq ends (positions.2 ▸ interpreted)⟩

theorem ActualSourceTrace.arguments {text : Source} {context : Predicate.Native.Context}
    {input info item offsets before after entries}
    (trace : ActualSourceTrace modelCalls text context.model input info item offsets before after entries)
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (beforeBound : before.cursor ≤ text.length + 1)
    (capacity : item.formalFirst + item.count - 1 ≤ info.parameters.length)
    (each : ∀ index ∈ offsets, index < item.count) :
    ∀ entry ∈ entries, ∃ argument, ArgumentAt text context input (info.parameterAt entry.1) entry.2 argument := by
  induction trace with
  | nil => simp
  | @cons index rest before middle after first entries step tail ih =>
    have indexIn := each index (List.mem_cons_self ..)
    have inside := association_slot_range step.association (Nat.ne_of_gt step.positive) (by omega) (by omega)
    have bounded := (PackageBindings.Metadata.parameterAt_typed typed step.positive
      (by omega : first.1 ≤ info.parameters.length)).2.2.2.2.1
    intro entry present
    rcases List.mem_cons.mp present with same | later
    · subst entry
      exact step.argument textValid valid body storage checked beforeBound bounded
    · exact ih (step.cursor_bounds beforeBound).2 (fun i h => each i (List.mem_cons_of_mem _ h)) entry later

end Silver.ApplicationPackageCalls
