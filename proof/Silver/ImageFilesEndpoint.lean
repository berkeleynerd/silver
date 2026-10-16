module

public import Silver.ImageFilesSource
public import Silver.ImageModelByteCount

@[expose] public section
namespace Silver.ImageModel.FilesSource
open FilesNative

section NativeExecution
variable (tables : Native.Tables) (nativeHelpers : Core.Helpers)
    (helpers : SourceBridge.NativeHelperBodies tables nativeHelpers)
    (runStructural runConsume : Core.State → Nat → Core.State)
    (scanner : SourceBridge.InterpretedScanner
      (SourceBridge.totalizedHelpers tables nativeHelpers) runStructural runConsume)
    (runFinish : FinishNative.Input → FinishNative.Plan)
    (finish : SourceBridge.InterpretedFinish runFinish)
    (initial : Core.State) (initialSource : SourceBridge.InterpretedInitial initial)
    (before after : Frame) (empty : before.read = []) (started : before.current = initial)

include tables nativeHelpers helpers runStructural scanner finish initial initialSource empty started

/-- The accepted native Plan counts the actual consumed bytes. The count is
derived from the initialized native loop and scanner, not supplied by the caller. -/
theorem accepted_plan_bytes (command : Command)
    (selected : command = snapshot ∨ command = refine)
    (execution : LoopRun command runConsume before after)
    (accepted : (runFinish after.current.finishView).kind ≠ .invalid) :
    (runFinish after.current.finishView).bytes = after.read.length := by
  have computation := initialized_plan command selected tables nativeHelpers helpers
    runStructural runConsume scanner runFinish finish initial initialSource
    before after empty started execution
  rw [computation] at accepted ⊢
  exact ScannerNative.successful_plan_bytes tables after.read accepted

/-- The actual initialized native scanner establishes both insertion bounds
relative to the recorded input, without an external offset/length premise. -/
theorem refined_plan_bounds (command : Command)
    (selected : command = snapshot ∨ command = refine)
    (execution : LoopRun command runConsume before after)
    (refined : (runFinish after.current.finishView).kind = .refine) :
    (runFinish after.current.finishView).declarations < (runFinish after.current.finishView).includes ∧
    (runFinish after.current.finishView).includes < after.read.length := by
  have computation := initialized_plan command selected tables nativeHelpers helpers
    runStructural runConsume scanner runFinish finish initial initialSource
    before after empty started execution
  have accepted : (runFinish after.current.finishView).kind ≠ .invalid := by rw [refined]; decide
  have bytes := accepted_plan_bytes tables nativeHelpers helpers runStructural runConsume scanner
    runFinish finish initial initialSource before after empty started command selected execution accepted
  rw [computation] at refined ⊢
  have offsets := FinishNative.refine_offsets _ refined
  have count := ScannerNative.finish_bytes
    (after.read.foldl (ScannerNative.consume (Core.modelHelpers tables)) {})
  rw [computation] at bytes
  have counted : (after.read.foldl (ScannerNative.consume (Core.modelHelpers tables)) {}).finishView.bytes = after.read.length := by
    change (after.read.foldl (ScannerNative.consume (Core.modelHelpers tables)) {}).bytes = after.read.length
    exact count.symm.trans bytes
  constructor
  · rw [offsets.1, offsets.2.1]
    exact offsets.2.2.1
  · rw [offsets.2.1]
    simpa only [counted] using offsets.2.2.2

/-- Successful native Refine supplies the independently quantified
Spliced_Prefix postcondition checked by SPARK and interpreted in FilesSplice.
Combined with the actual read/scanner trace, it determines the exact output;
removing only the two added spans recovers every original byte. Fragment
identity and JSON interpretation are composed separately at the Image endpoint. -/
theorem refined_file_preserves
    (execution : LoopRun refine runConsume before after)
    (refined : (runFinish after.current.finishView).kind = .refine)
    (output declarations includes : List Nat)
    (contract : FilesSplice.expression.eval
      { original := after.read, refined := output, declarations, includes,
        count := (runFinish after.current.finishView).bytes,
        declarationsOffset := (runFinish after.current.finishView).declarations,
        includesOffset := (runFinish after.current.finishView).includes }) :
    output = splice after.read declarations includes
      (runFinish after.current.finishView).declarations (runFinish after.current.finishView).includes ∧
    eraseInsertions output (runFinish after.current.finishView).declarations
      (runFinish after.current.finishView).includes declarations.length includes.length = after.read := by
  have bounds := refined_plan_bounds tables nativeHelpers helpers runStructural runConsume scanner
    runFinish finish initial initialSource before after empty started refine (.inr rfl) execution refined
  have accepted : (runFinish after.current.finishView).kind ≠ .invalid := by rw [refined]; decide
  have bytes := accepted_plan_bytes tables nativeHelpers helpers runStructural runConsume scanner
    runFinish finish initial initialSource before after empty started refine (.inr rfl) execution accepted
  have exactOutput := FilesSplice.exact_splice
    { original := after.read, refined := output, declarations, includes,
      count := (runFinish after.current.finishView).bytes,
      declarationsOffset := (runFinish after.current.finishView).declarations,
      includesOffset := (runFinish after.current.finishView).includes }
    bounds.1 (by simpa only [bytes] using bounds.2) contract
  change output = splice after.read declarations includes
    (runFinish after.current.finishView).declarations (runFinish after.current.finishView).includes at exactOutput
  refine ⟨exactOutput, ?_⟩
  rw [exactOutput]
  exact erase_splice after.read declarations includes _ _ (by omega) (by omega)

end NativeExecution
end Silver.ImageModel.FilesSource
