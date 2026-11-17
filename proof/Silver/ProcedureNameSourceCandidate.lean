module

public import Silver.ProcedureNameSource
public import Silver.ReviewedOutputShape
public import Silver.ProcedureNameSourceParts.StepSpec
public import Silver.ProcedureNameSourceParts.StepImpl
public import Silver.ProcedureNameSourceParts.ModelSpec
public import Silver.ProcedureNameSourceParts.ModelImpl
public import Silver.ProcedureNameSourceParts.LoopSpec
public import Silver.ProcedureNameSourceParts.LoopImpl
public import Silver.ProcedureNameSourceParts.Record
public import Silver.ProcedureNameSourceParts.Step
public import Silver.ProcedureNameSourceParts.Model
public import Silver.ProcedureNameSourceParts.Loop

@[expose] public section

namespace Silver.ProcedureNameSourceCandidate
open Predicate.ProcedureNameNative

/-- The complete lexical helper shapes and their structural guards are checked
against the reviewed whole-file pin. The authoritative adapter supplies its
separate equality to the certified Ada tokens. -/
theorem checked : SourceChecks.Checked Output.SourceShape.outputImplementation where
  stepTree := stepBody_checked
  modelTree := freeBody_checked
  headers := by
    intro item present
    simp only [SourceChecks.headers, List.mem_cons, List.mem_nil_iff, or_false] at present
    rcases present with rfl | rfl | rfl | rfl | rfl | rfl
    · exact Parts.header_0
    · exact Parts.header_1
    · exact Parts.header_2
    · exact Parts.header_3
    · exact Parts.header_4
    · exact Parts.header_5
  record := Parts.record
  step := Parts.step
  model := Parts.model
  loop := Parts.loop

end Silver.ProcedureNameSourceCandidate

