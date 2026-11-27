module

public import Silver.ApplicationPackageCallValidityImports
public import Silver.ApplicationPackageCallContract
public import Silver.ApplicationPackageCallsDenotation

@[expose] public section

namespace Silver.ApplicationPackageCalls.SourceLibraries
open Compose Compose.Expressions Predicate ApplicationPackages

set_option backward.dsimp.instances true

theorem scalar_storage {text : Source} {native : Predicate.Native.Context}
    (valid : Predicate.Native.ValidContext text native) : ValidityImports.ScalarStorage native.model := by
  intro index
  have environment := valid.2.2.1
  unfold ScalarExpression.binding
  cases found : native.scalarNames[index - 1]? with
  | none =>
    simp only [Predicate.Native.Context.model, List.getD_eq_getElem?_getD, found, Option.getD_none]
    exact ⟨Integer.Interval.empty_bounded, Integer.Interval.empty_bounded⟩
  | some item =>
    have typed := environment.2 item (List.mem_of_getElem? found)
    simpa only [Predicate.Native.Context.model, List.getD_eq_getElem?_getD, found, Option.getD_some] using
      (show item.bounds.Bounded ∧ item.declaredBounds.Bounded from ⟨typed.2.2.2.1, typed.2.2.2.2.1⟩)

structure Libraries where
  payload : PayloadImports.Library
  validity : ValidityImports.Library

namespace Libraries

def other (library : Libraries) : Calls := {modelCalls with validBody := library.validity.calls.body}

noncomputable def calls (library : Libraries) : Calls := library.payload.calls library.other

theorem validity_meaning (library : Libraries) (prior : ApplicationNative.Locals)
    (text : Source) (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (scan : BodyScan)
    (storage : ValidityNative.FlowStorage scan.facts) :
    (library.calls).validBody text native.model scan = bodyValidCheck text native.model scan := by
  let locals := ((prior.set .source "text" text).set .parseContext "context" native.model).set .bodyScan "scan" scan
  exact library.validity.body locals valid (scalar_storage contextValid) storage.intervals

/-- The complete original call model is connected to the native inherited
libraries. Metadata hypotheses are native field subtypes only. Input validity
is the original source-defined Valid_Body predicate, never callee acceptance. -/
theorem call_meaning (library : Libraries) (prior : ApplicationNative.Locals)
    (text : Source) (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (input : ApplicationScan)
    (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : (library.calls).validBody text native.model input.scan = true)
    (info : PackageBindings.Metadata) (typed : info.Typed) (position : Nat)
    (bounded : ValidCursor text position) (kind : PackageBindings.RoutineKind) :
    packageCallAt library.calls text native.model input info position kind =
      packageCallAt modelCalls text native.model input info position kind := by
  have modelInput : bodyValidCheck text native.model input.scan = true := by
    rw [← library.validity_meaning prior text valid native contextValid input.scan storage]
    exact checked
  have flow := (ValidityNative.body_import_domain text native input.scan storage modelInput).2.2
  have contextDomain := ApplicationPackageEffects.LookupDomain.of_native contextValid
  have callee : packageCallee library.calls text native.model info position kind =
      packageCallee modelCalls text native.model info position kind :=
    LexicalImports.callee library.payload.effects library.other text valid native.model contextDomain info position bounded kind
  have reference : library.calls.reference text position = QualifiedNames.read text position :=
    ScalarExpression.SourceBridge.interpreted_readReference library.payload.effects.scalars
      library.payload.effects.scalarSource text valid position bounded
  have afterName := QualifiedNames.read_after_bound text position bounded
  have stages : callStages library.calls text native.model input info position kind =
      callStages modelCalls text native.model input info position kind := by
    dsimp only [calls] at callee reference ⊢
    unfold callStages
    rw [callee]
    dsimp only
    split
    · rfl
    · split
      · rfl
      · rw [reference]
        simp only [show modelCalls.reference = QualifiedNames.read from rfl]
        rw [library.payload.read_actuals library.other text valid native contextValid input flow info typed _ _ afterName]
        cases read : readActuals modelCalls text native.model input info
            (info.routineAt (packageCallee modelCalls text native.model info position kind))
            (QualifiedNames.read text position).after with
        | none => rfl
        | some frame =>
          simp only [Option.bind_eq_bind, Option.bind_some]
          have rows := PayloadImports.model_read_bounds valid native contextValid input info _ _ frame read
          rw [library.payload.aliases library.other text valid info _ frame rows]
          cases aliases : checkAliases modelCalls text info
              (info.routineAt (packageCallee modelCalls text native.model info position kind)) frame with
          | none => rfl
          | some result =>
            simp only [Option.bind_some]
            rw [library.payload.finish_call library.other text valid native.model contextDomain info kind _ frame result]
            have stored : CallStorage input (finishCall modelCalls text native.model info kind
                (info.routineAt (packageCallee modelCalls text native.model info position kind)) frame result) := finishCall_storage
              (aliases_storage typed (readActuals_storage storage read) aliases) contextValid.2.2.1
            have validity := library.validity_meaning prior text valid native contextValid _ stored.flow
            dsimp only [calls] at validity
            rw [validity]
            rfl
  unfold packageCallAt
  rw [stages]

/-- The typed complete native body has the same result for arbitrary scratch
locals; its original declarations and every rejected path remain included. -/
theorem native_meaning (library : Libraries) (locals : ApplicationNative.Locals)
    (native : Predicate.Native.Context) (same : locals .parseContext "context" = native.model)
    (valid : ValidText (locals .source "text"))
    (contextValid : Predicate.Native.ValidContext (locals .source "text") native)
    (storage : ValidityNative.FlowStorage (locals .appScan "input").scan.facts)
    (checked : library.calls.validBody (locals .source "text") native.model (locals .appScan "input").scan = true)
    (typed : (locals .metadata "info").Typed)
    (bounded : ValidCursor (locals .source "text") (locals .number "position")) :
    Native.Call.callBody.eval (resultType := .appCall) (Native.Call.imported library.calls) locals =
      packageCallAt modelCalls (locals .source "text") native.model (locals .appScan "input")
        (locals .metadata "info") (locals .number "position") (locals .routineKind "kind") := by
  have capacity : (locals .metadata "info").parameters.length ≤ PackageBindings.maxFormals := typed.2.2.2.2.2.2.2.1
  rw [Native.Call.call_denotation library.calls locals capacity, same]
  exact library.call_meaning locals _ valid native contextValid _ storage checked _ typed _ bounded _

end Libraries
end Silver.ApplicationPackageCalls.SourceLibraries
