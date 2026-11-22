module

public import Silver.ProcedureMetadataSourceChecks
public import Silver.ProcedureMetadataMeaning
public import Silver.PredicateSourceBridge

@[expose] public section

namespace Silver.Predicate.ProcedureMetadataNative

/-- Raw selector equations and exact native callee links. The executable
Read_Form equality is its source-checked Static postcondition, independently
discharged by the complete native proof. No complete scanner law is assumed. -/
structure LinkedSource (implementation : Implementation.Calls) (metadata : Calls) : Prop where
  definitions : Equations metadata
  form : metadata.form .model = implementation.outer.formResult
  readForm : ∀ text form, metadata.form .executable text form = metadata.form .model text form

theorem linked_form_imports (implementation : Implementation.Calls)
    (source : SourceBridge.InterpretedSource implementation) (metadata : Calls)
    (linked : LinkedSource implementation metadata) : FormImports metadata where
  model text form := by
    rw [linked.form]
    exact Outer.interpreted_form implementation.outer
      (SourceBridge.interpreted_helpers implementation source)
      (Implementation.body_meaning implementation
        (Compose.SourceBridge.interpreted_equations implementation.outer.helpers source.helpers)
        source.definitions (Compose.SourceBridge.interpreted_primitives implementation.outer.helpers source.helpers))
      source.definitions.outer text form
  executable := linked.readForm

/-- Source admission, exact metadata selection and nominal formal type
resolution share one interpreted scanner and the same selected accepted scan.
The procedure count remains the count used by the native report inventory and
its full-domain no-inlining selection. -/
theorem actual_source_correspondence :
    SourceBridge.CheckedSource ∧
    SourceChecks.Checked Source.outputSpecTokens Source.outputBodyTokens ∧
    ∀ implementation, SourceBridge.InterpretedSource implementation →
      ∀ metadata, LinkedSource implementation metadata → ∀ text program,
        SourceMeaning text program →
        ProcedureBindings.catalogSignatures (metadata.executable text)
          (selectTypes (metadata.form .executable) text) =
          program.procedures.map ScalarProcedures.Definition.signature ∧
        (metadata.executable text).items.length = program.procedures.length := by
  refine ⟨SourceBridge.checked_source, Silver.ProcedureMetadataSourceChecks.checked_source, ?_⟩
  intro implementation source metadata linked text program meaning
  have imports := linked_form_imports implementation source metadata linked
  exact ⟨executable_catalog metadata linked.definitions imports meaning,
    executable_count metadata linked.definitions imports meaning⟩

def modelCalls : Calls where
  form _ := formResult
  model := procedureModel
  executable := procedureModel

theorem model_equations : Equations modelCalls where
  model text := (model_denotation modelCalls text _).symm
  executable text := (executable_denotation modelCalls text _).symm

theorem model_linked : LinkedSource Implementation.modelCalls modelCalls where
  definitions := model_equations
  form := rfl
  readForm _ _ := rfl

end Silver.Predicate.ProcedureMetadataNative
